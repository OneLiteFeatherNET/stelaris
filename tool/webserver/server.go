package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"io/fs"
	"log/slog"
	"net/http"
	"path"
	"sort"
	"strconv"
	"strings"
	"time"
)

// indexFile is the application shell. Every route that go_router owns resolves
// to it, mirroring nginx's `try_files $uri $uri/ /index.html`.
const indexFile = "index.html"

// healthPath is answered by the server itself so the container needs no shell
// and no curl for its health check.
const healthPath = "/healthz"

// entryPoints are never cached beyond a revalidation, whatever
// STELARIS_ASSET_CACHE_CONTROL says. A stale shell or service worker pins a
// browser to a build that no longer exists on the server, and that failure mode
// is invisible until someone hard-reloads.
var entryPoints = map[string]bool{
	indexFile:                   true,
	"flutter.js":                true,
	"flutter_bootstrap.js":      true,
	"flutter_service_worker.js": true,
	"manifest.json":             true,
	"version.json":              true,
}

// contentTypes is an explicit table instead of mime.TypeByExtension because a
// scratch image has no /etc/mime.types, and because two of these are load
// bearing: WebAssembly.instantiateStreaming rejects anything that is not
// exactly application/wasm, and the .mjs entrypoint must be served as
// JavaScript or the module import fails.
var contentTypes = map[string]string{
	".bin":     "application/octet-stream",
	".css":     "text/css; charset=utf-8",
	".html":    "text/html; charset=utf-8",
	".ico":     "image/x-icon",
	".jpg":     "image/jpeg",
	".jpeg":    "image/jpeg",
	".js":      "text/javascript; charset=utf-8",
	".json":    "application/json; charset=utf-8",
	".map":     "application/json; charset=utf-8",
	".mjs":     "text/javascript; charset=utf-8",
	".otf":     "font/otf",
	".png":     "image/png",
	".svg":     "image/svg+xml",
	".symbols": "text/plain; charset=utf-8",
	".ttf":     "font/ttf",
	".txt":     "text/plain; charset=utf-8",
	".wasm":    "application/wasm",
	".webp":    "image/webp",
	".woff":    "font/woff",
	".woff2":   "font/woff2",
	".xml":     "application/xml; charset=utf-8",
}

// asset holds everything about one bundle file that can be computed once. The
// bundle is baked into the binary and therefore immutable for the lifetime of
// the process, so nothing here is ever invalidated.
type asset struct {
	name         string // path inside the bundle, e.g. "assets/NOTICES"
	gzipName     string // precompressed sibling, empty when there is none
	contentType  string
	cacheControl string
	size         int64
	gzipSize     int64
	etag         string
	gzipETag     string
}

// Server serves a compiled Flutter web bundle and nothing else: no directory
// listings, no uploads, no proxying, no server-side templating.
type Server struct {
	fsys    fs.FS
	cfg     Config
	log     *slog.Logger
	assets  map[string]*asset
	index   *asset
	headers [][2]string // security headers, materialised once
}

// NewServer indexes the bundle and precomputes every response header that does
// not depend on the request.
func NewServer(fsys fs.FS, cfg Config, log *slog.Logger) (*Server, error) {
	s := &Server{
		fsys:   fsys,
		cfg:    cfg,
		log:    log,
		assets: make(map[string]*asset),
	}

	if err := s.indexBundle(); err != nil {
		return nil, err
	}
	if s.index == nil {
		return nil, fmt.Errorf("bundle contains no %s - was the Flutter web build copied into the image?", indexFile)
	}
	s.headers = buildSecurityHeaders(cfg)
	return s, nil
}

// indexBundle walks the bundle once and fills the asset table.
func (s *Server) indexBundle() error {
	gzipped := make(map[string]int64)

	err := fs.WalkDir(s.fsys, ".", func(name string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		info, err := d.Info()
		if err != nil {
			return err
		}
		if strings.HasSuffix(name, ".gz") {
			gzipped[strings.TrimSuffix(name, ".gz")] = info.Size()
			return nil
		}

		sum, err := s.hash(name)
		if err != nil {
			return err
		}
		ext := strings.ToLower(path.Ext(name))
		s.assets[name] = &asset{
			name:         name,
			contentType:  contentTypeFor(ext),
			cacheControl: s.cacheControlFor(name),
			size:         info.Size(),
			etag:         `"` + sum + `"`,
		}
		return nil
	})
	if err != nil {
		return err
	}

	// Wire up the precompressed siblings produced at image build time.
	for name, size := range gzipped {
		a, ok := s.assets[name]
		if !ok {
			continue
		}
		a.gzipName = name + ".gz"
		a.gzipSize = size
		// A different encoding is a different representation and must not share
		// an ETag, or a caching proxy can hand a gzip body to a client that did
		// not ask for one.
		a.gzipETag = strings.TrimSuffix(a.etag, `"`) + `-gz"`
	}

	s.index = s.assets[indexFile]
	return nil
}

func (s *Server) hash(name string) (string, error) {
	f, err := s.fsys.Open(name)
	if err != nil {
		return "", err
	}
	defer f.Close()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		return "", err
	}
	// 128 bits of a SHA-256 is plenty for cache validation and keeps the header
	// short.
	return hex.EncodeToString(h.Sum(nil))[:32], nil
}

func (s *Server) cacheControlFor(name string) string {
	if entryPoints[name] {
		return "no-cache"
	}
	return s.cfg.AssetCacheControl
}

func contentTypeFor(ext string) string {
	if ct, ok := contentTypes[ext]; ok {
		return ct
	}
	// Flutter emits extensionless files (assets/NOTICES). Anything unknown is
	// served as an opaque download rather than guessed at, and nosniff keeps the
	// browser from second-guessing that.
	return "application/octet-stream"
}

// buildSecurityHeaders materialises the headers that are identical on every
// response, so the hot path is a slice append instead of a config lookup.
func buildSecurityHeaders(cfg Config) [][2]string {
	headers := [][2]string{
		// The bundle's content types are exact (see contentTypes), so sniffing
		// can only ever get it wrong.
		{"X-Content-Type-Options", "nosniff"},
		// Belt and braces with frame-ancestors for browsers that predate CSP3.
		{"X-Frame-Options", "DENY"},
		{"Referrer-Policy", "no-referrer"},
		// The bundle is only ever loaded by its own origin.
		{"Cross-Origin-Resource-Policy", "same-origin"},
		{"Permissions-Policy", "accelerometer=(), autoplay=(), camera=(), display-capture=(), encrypted-media=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), midi=(), payment=(), usb=()"},
	}
	if cfg.CSP != "" {
		headers = append(headers, [2]string{"Content-Security-Policy", cfg.CSP})
	}
	if cfg.CrossOriginIsolation {
		headers = append(headers,
			[2]string{"Cross-Origin-Opener-Policy", "same-origin"},
			[2]string{"Cross-Origin-Embedder-Policy", cfg.COEP},
		)
	}
	return headers
}

func (s *Server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
	s.serve(rec, r)

	if s.cfg.AccessLog {
		// The query string is deliberately not logged: it is attacker- and
		// user-controlled and can carry tokens.
		s.log.Info("request",
			slog.String("method", r.Method),
			slog.String("path", r.URL.Path),
			slog.Int("status", rec.status),
			slog.Int64("bytes", rec.written),
			slog.Duration("duration", time.Since(start)),
		)
	}
}

func (s *Server) serve(w http.ResponseWriter, r *http.Request) {
	for _, h := range s.headers {
		w.Header().Set(h[0], h[1])
	}

	// A static bundle is read-only by definition. Anything that is not a read
	// is rejected before it can touch the file lookup.
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		w.Header().Set("Allow", "GET, HEAD")
		httpError(w, r, http.StatusMethodNotAllowed)
		return
	}

	if r.URL.Path == healthPath {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.Header().Set("Cache-Control", "no-store")
		w.WriteHeader(http.StatusOK)
		if r.Method == http.MethodGet {
			io.WriteString(w, "ok\n")
		}
		return
	}

	name, ok := bundlePath(r.URL.Path)
	if !ok {
		httpError(w, r, http.StatusBadRequest)
		return
	}

	if a, found := s.assets[name]; found {
		s.write(w, r, a, http.StatusOK)
		return
	}

	// try_files $uri $uri/ /index.html: go_router owns every path that is not a
	// file, so a deep link has to return the shell. A request that looks like a
	// missing asset gets an honest 404 instead - answering those with HTML
	// breaks streaming Wasm instantiation and hides broken builds.
	if looksLikeAsset(name) {
		httpError(w, r, http.StatusNotFound)
		return
	}
	s.write(w, r, s.index, http.StatusOK)
}

// bundlePath maps a request path onto a path inside the bundle. It returns
// false for paths that cannot be served at all.
func bundlePath(urlPath string) (string, bool) {
	if strings.ContainsRune(urlPath, 0) {
		return "", false
	}
	if !strings.HasPrefix(urlPath, "/") {
		urlPath = "/" + urlPath
	}
	// path.Clean resolves . and .. segments; because the result stays rooted at
	// "/" it can never escape the bundle, and the FS is read-only anyway.
	cleaned := path.Clean(urlPath)
	if cleaned == "/" {
		return indexFile, true
	}
	name := strings.TrimPrefix(cleaned, "/")
	if name == "" || strings.HasPrefix(name, "../") {
		return "", false
	}
	return name, true
}

// looksLikeAsset reports whether a miss should be a 404 rather than the app
// shell. Anything with a file extension in its last segment is a file request.
func looksLikeAsset(name string) bool {
	return path.Ext(path.Base(name)) != ""
}

func (s *Server) write(w http.ResponseWriter, r *http.Request, a *asset, status int) {
	useGzip := a.gzipName != "" && acceptsGzip(r)

	etag := a.etag
	size := a.size
	if useGzip {
		etag = a.gzipETag
		size = a.gzipSize
		w.Header().Set("Content-Encoding", "gzip")
	}
	if a.gzipName != "" {
		w.Header().Set("Vary", "Accept-Encoding")
	}

	w.Header().Set("Content-Type", a.contentType)
	w.Header().Set("Cache-Control", a.cacheControl)
	w.Header().Set("ETag", etag)

	if matchesETag(r.Header.Get("If-None-Match"), etag) {
		w.WriteHeader(http.StatusNotModified)
		return
	}

	w.Header().Set("Content-Length", strconv.FormatInt(size, 10))
	w.WriteHeader(status)
	if r.Method == http.MethodHead {
		return
	}

	name := a.name
	if useGzip {
		name = a.gzipName
	}
	f, err := s.fsys.Open(name)
	if err != nil {
		// The table was built from this same FS at startup, so this only
		// happens if the FS lied to us. The status line is already on the wire.
		s.log.Error("open bundle file", slog.String("file", name), slog.Any("error", err))
		return
	}
	defer f.Close()

	if _, err := io.Copy(w, f); err != nil {
		s.log.Debug("write response", slog.String("file", name), slog.Any("error", err))
	}
}

func acceptsGzip(r *http.Request) bool {
	for _, part := range strings.Split(r.Header.Get("Accept-Encoding"), ",") {
		token, params, _ := strings.Cut(strings.TrimSpace(part), ";")
		if !strings.EqualFold(strings.TrimSpace(token), "gzip") {
			continue
		}
		// "gzip;q=0" is an explicit refusal.
		if q, ok := strings.CutPrefix(strings.TrimSpace(params), "q="); ok {
			if v, err := strconv.ParseFloat(strings.TrimSpace(q), 64); err == nil && v == 0 {
				return false
			}
		}
		return true
	}
	return false
}

func matchesETag(header, etag string) bool {
	if header == "" {
		return false
	}
	for _, candidate := range strings.Split(header, ",") {
		candidate = strings.TrimSpace(candidate)
		if candidate == "*" || candidate == etag {
			return true
		}
		// A weak validator still identifies the same representation.
		if strings.TrimPrefix(candidate, "W/") == etag {
			return true
		}
	}
	return false
}

// httpError answers with a bare text body: no stack traces, no paths, no
// Go version, nothing that describes the server.
func httpError(w http.ResponseWriter, r *http.Request, status int) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.Header().Del("Content-Encoding")
	w.WriteHeader(status)
	if r.Method != http.MethodHead {
		fmt.Fprintln(w, http.StatusText(status))
	}
}

// statusRecorder captures what was actually sent, for the access log.
type statusRecorder struct {
	http.ResponseWriter
	status  int
	written int64
	wrote   bool
}

func (s *statusRecorder) WriteHeader(status int) {
	if s.wrote {
		return
	}
	s.wrote = true
	s.status = status
	s.ResponseWriter.WriteHeader(status)
}

func (s *statusRecorder) Write(b []byte) (int, error) {
	if !s.wrote {
		s.WriteHeader(http.StatusOK)
	}
	n, err := s.ResponseWriter.Write(b)
	s.written += int64(n)
	return n, err
}

// bundleFiles lists the indexed files, sorted. Used by the startup log so an
// operator can see what actually made it into the image.
func (s *Server) bundleFiles() []string {
	names := make([]string, 0, len(s.assets))
	for name := range s.assets {
		names = append(names, name)
	}
	sort.Strings(names)
	return names
}
