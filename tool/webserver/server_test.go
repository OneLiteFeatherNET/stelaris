package main

import (
	"bytes"
	"compress/gzip"
	"io"
	"io/fs"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"
	"testing/fstest"
)

const indexBody = "<!DOCTYPE html><html><body>shell</body></html>"

func gzipBytes(t *testing.T, in string) []byte {
	t.Helper()
	var buf bytes.Buffer
	w := gzip.NewWriter(&buf)
	if _, err := io.WriteString(w, in); err != nil {
		t.Fatalf("gzip write: %v", err)
	}
	if err := w.Close(); err != nil {
		t.Fatalf("gzip close: %v", err)
	}
	return buf.Bytes()
}

// testBundle mirrors the shape of a real `flutter build web --wasm` output:
// an entry point, a Wasm module, an extensionless asset and a precompressed
// sibling.
func testBundle(t *testing.T) fs.FS {
	t.Helper()
	return fstest.MapFS{
		"index.html":                {Data: []byte(indexBody)},
		"index.html.gz":             {Data: gzipBytes(t, indexBody)},
		"flutter_service_worker.js": {Data: []byte("// sw")},
		"main.dart.wasm":            {Data: []byte("\x00asm")},
		"main.dart.mjs":             {Data: []byte("export default 1;")},
		"assets/NOTICES":            {Data: []byte("licenses")},
		"canvaskit/canvaskit.wasm":  {Data: []byte("\x00asm")},
	}
}

func newTestServer(t *testing.T, cfg Config) *Server {
	t.Helper()
	srv, err := NewServer(testBundle(t), cfg, slog.New(slog.DiscardHandler))
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}
	return srv
}

func testConfig() Config {
	cfg := LoadConfig(func(string) (string, bool) { return "", false })
	cfg.AccessLog = false
	return cfg
}

func do(t *testing.T, srv *Server, method, target string, headers map[string]string) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequest(method, target, nil)
	for k, v := range headers {
		req.Header.Set(k, v)
	}
	rec := httptest.NewRecorder()
	srv.ServeHTTP(rec, req)
	return rec
}

func TestServesIndexForRoot(t *testing.T) {
	srv := newTestServer(t, testConfig())

	rec := do(t, srv, http.MethodGet, "/", nil)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", rec.Code)
	}
	if got := rec.Body.String(); got != indexBody {
		t.Errorf("body = %q, want the app shell", got)
	}
	if got := rec.Header().Get("Content-Type"); got != "text/html; charset=utf-8" {
		t.Errorf("Content-Type = %q", got)
	}
	if got := rec.Header().Get("Cache-Control"); got != "no-cache" {
		t.Errorf("Cache-Control = %q, entry points must revalidate", got)
	}
}

// go_router owns client-side routes, so a deep link must return the shell with
// a 200 instead of a 404.
func TestDeepLinkFallsBackToShell(t *testing.T) {
	srv := newTestServer(t, testConfig())

	for _, target := range []string{"/items", "/items/42", "/build/generate", "/some/deep/route/"} {
		rec := do(t, srv, http.MethodGet, target, nil)
		if rec.Code != http.StatusOK {
			t.Errorf("%s: status = %d, want 200", target, rec.Code)
		}
		if rec.Body.String() != indexBody {
			t.Errorf("%s: did not serve the app shell", target)
		}
	}
}

// A missing file must stay a 404. Answering it with HTML would break streaming
// Wasm instantiation and hide broken builds behind a working-looking page.
func TestMissingAssetIsNotFound(t *testing.T) {
	srv := newTestServer(t, testConfig())

	for _, target := range []string{"/missing.wasm", "/canvaskit/gone.js", "/assets/nope.png"} {
		rec := do(t, srv, http.MethodGet, target, nil)
		if rec.Code != http.StatusNotFound {
			t.Errorf("%s: status = %d, want 404", target, rec.Code)
		}
	}
}

func TestContentTypes(t *testing.T) {
	srv := newTestServer(t, testConfig())

	cases := map[string]string{
		// instantiateStreaming refuses anything but application/wasm.
		"/main.dart.wasm":           "application/wasm",
		"/canvaskit/canvaskit.wasm": "application/wasm",
		"/main.dart.mjs":            "text/javascript; charset=utf-8",
		// Flutter emits this without an extension.
		"/assets/NOTICES": "application/octet-stream",
	}
	for target, want := range cases {
		rec := do(t, srv, http.MethodGet, target, nil)
		if got := rec.Header().Get("Content-Type"); got != want {
			t.Errorf("%s: Content-Type = %q, want %q", target, got, want)
		}
	}
}

func TestOnlyReadMethodsAllowed(t *testing.T) {
	srv := newTestServer(t, testConfig())

	for _, method := range []string{http.MethodPost, http.MethodPut, http.MethodDelete, http.MethodPatch} {
		rec := do(t, srv, method, "/", nil)
		if rec.Code != http.StatusMethodNotAllowed {
			t.Errorf("%s: status = %d, want 405", method, rec.Code)
		}
		if got := rec.Header().Get("Allow"); got != "GET, HEAD" {
			t.Errorf("%s: Allow = %q", method, got)
		}
	}
}

func TestHeadHasHeadersButNoBody(t *testing.T) {
	srv := newTestServer(t, testConfig())

	rec := do(t, srv, http.MethodHead, "/main.dart.wasm", nil)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", rec.Code)
	}
	if rec.Body.Len() != 0 {
		t.Errorf("HEAD returned %d body bytes", rec.Body.Len())
	}
	if got := rec.Header().Get("Content-Length"); got != "4" {
		t.Errorf("Content-Length = %q, want 4", got)
	}
}

// The bundle FS is rooted, so traversal cannot escape it - but it must also not
// silently succeed with something unexpected.
func TestPathTraversalCannotEscapeBundle(t *testing.T) {
	srv := newTestServer(t, testConfig())

	for _, target := range []string{"/../../etc/passwd", "/..%2f..%2fetc%2fpasswd", "/./../../index.html"} {
		rec := do(t, srv, http.MethodGet, target, nil)
		body := rec.Body.String()
		if strings.Contains(body, "root:") {
			t.Fatalf("%s: leaked host file content", target)
		}
		if rec.Code != http.StatusOK && rec.Code != http.StatusNotFound && rec.Code != http.StatusBadRequest {
			t.Errorf("%s: unexpected status %d", target, rec.Code)
		}
	}
}

func TestSecurityHeaders(t *testing.T) {
	srv := newTestServer(t, testConfig())

	rec := do(t, srv, http.MethodGet, "/", nil)

	want := map[string]string{
		"X-Content-Type-Options":       "nosniff",
		"X-Frame-Options":              "DENY",
		"Referrer-Policy":              "no-referrer",
		"Cross-Origin-Resource-Policy": "same-origin",
	}
	for header, value := range want {
		if got := rec.Header().Get(header); got != value {
			t.Errorf("%s = %q, want %q", header, got, value)
		}
	}
	if got := rec.Header().Get("Permissions-Policy"); !strings.Contains(got, "camera=()") {
		t.Errorf("Permissions-Policy = %q", got)
	}

	csp := rec.Header().Get("Content-Security-Policy")
	// Without these the Flutter engine does not start at all, so they are as
	// much a functional contract as a security one.
	for _, directive := range []string{"'wasm-unsafe-eval'", "worker-src 'self' blob:", "frame-ancestors 'none'", "connect-src 'self' https:"} {
		if !strings.Contains(csp, directive) {
			t.Errorf("CSP is missing %q: %s", directive, csp)
		}
	}
}

func TestCrossOriginIsolationIsOptIn(t *testing.T) {
	off := newTestServer(t, testConfig())
	rec := do(t, off, http.MethodGet, "/", nil)
	if got := rec.Header().Get("Cross-Origin-Opener-Policy"); got != "" {
		t.Errorf("COOP = %q, want unset by default", got)
	}

	cfg := testConfig()
	cfg.CrossOriginIsolation = true
	on := newTestServer(t, cfg)
	rec = do(t, on, http.MethodGet, "/", nil)
	if got := rec.Header().Get("Cross-Origin-Opener-Policy"); got != "same-origin" {
		t.Errorf("COOP = %q, want same-origin", got)
	}
	if got := rec.Header().Get("Cross-Origin-Embedder-Policy"); got != "credentialless" {
		t.Errorf("COEP = %q, want credentialless", got)
	}
}

func TestCSPCanBeDisabled(t *testing.T) {
	cfg := testConfig()
	cfg.CSP = ""
	srv := newTestServer(t, cfg)

	rec := do(t, srv, http.MethodGet, "/", nil)

	if got := rec.Header().Get("Content-Security-Policy"); got != "" {
		t.Errorf("CSP = %q, want no header", got)
	}
}

func TestETagRevalidation(t *testing.T) {
	srv := newTestServer(t, testConfig())

	first := do(t, srv, http.MethodGet, "/main.dart.wasm", nil)
	etag := first.Header().Get("ETag")
	if etag == "" {
		t.Fatal("no ETag on first response")
	}

	second := do(t, srv, http.MethodGet, "/main.dart.wasm", map[string]string{"If-None-Match": etag})
	if second.Code != http.StatusNotModified {
		t.Errorf("status = %d, want 304", second.Code)
	}
	if second.Body.Len() != 0 {
		t.Errorf("304 carried %d body bytes", second.Body.Len())
	}

	weak := do(t, srv, http.MethodGet, "/main.dart.wasm", map[string]string{"If-None-Match": "W/" + etag})
	if weak.Code != http.StatusNotModified {
		t.Errorf("weak validator: status = %d, want 304", weak.Code)
	}
}

func TestPrecompressedVariant(t *testing.T) {
	srv := newTestServer(t, testConfig())

	compressed := do(t, srv, http.MethodGet, "/", map[string]string{"Accept-Encoding": "gzip, deflate, br"})
	if got := compressed.Header().Get("Content-Encoding"); got != "gzip" {
		t.Fatalf("Content-Encoding = %q, want gzip", got)
	}
	if got := compressed.Header().Get("Vary"); got != "Accept-Encoding" {
		t.Errorf("Vary = %q", got)
	}
	length, err := strconv.Atoi(compressed.Header().Get("Content-Length"))
	if err != nil || length != compressed.Body.Len() {
		t.Errorf("Content-Length = %q, body = %d bytes", compressed.Header().Get("Content-Length"), compressed.Body.Len())
	}
	gz, err := gzip.NewReader(bytes.NewReader(compressed.Body.Bytes()))
	if err != nil {
		t.Fatalf("response is not valid gzip: %v", err)
	}
	decoded, err := io.ReadAll(gz)
	if err != nil {
		t.Fatalf("gzip read: %v", err)
	}
	if string(decoded) != indexBody {
		t.Errorf("decompressed body = %q", decoded)
	}

	plain := do(t, srv, http.MethodGet, "/", nil)
	if got := plain.Header().Get("Content-Encoding"); got != "" {
		t.Errorf("Content-Encoding = %q without Accept-Encoding", got)
	}
	if plain.Body.String() != indexBody {
		t.Errorf("uncompressed body = %q", plain.Body.String())
	}

	// A shared ETag across encodings lets a proxy hand a gzip body to a client
	// that never asked for one.
	if compressed.Header().Get("ETag") == plain.Header().Get("ETag") {
		t.Error("gzip and identity responses share an ETag")
	}
}

func TestGzipRefusedWithQualityZero(t *testing.T) {
	srv := newTestServer(t, testConfig())

	rec := do(t, srv, http.MethodGet, "/", map[string]string{"Accept-Encoding": "gzip;q=0"})

	if got := rec.Header().Get("Content-Encoding"); got != "" {
		t.Errorf("Content-Encoding = %q, client refused gzip", got)
	}
}

func TestGzipSiblingIsNotServedDirectly(t *testing.T) {
	srv := newTestServer(t, testConfig())

	rec := do(t, srv, http.MethodGet, "/index.html.gz", nil)

	if rec.Code != http.StatusNotFound {
		t.Errorf("status = %d, want 404 - the .gz sibling is an implementation detail", rec.Code)
	}
}

func TestHealthEndpoint(t *testing.T) {
	srv := newTestServer(t, testConfig())

	rec := do(t, srv, http.MethodGet, healthPath, nil)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", rec.Code)
	}
	if got := rec.Header().Get("Cache-Control"); got != "no-store" {
		t.Errorf("Cache-Control = %q", got)
	}
	if !strings.HasPrefix(rec.Body.String(), "ok") {
		t.Errorf("body = %q", rec.Body.String())
	}
}

func TestAssetCacheControlDoesNotApplyToEntryPoints(t *testing.T) {
	cfg := testConfig()
	cfg.AssetCacheControl = "public, max-age=31536000, immutable"
	srv := newTestServer(t, cfg)

	asset := do(t, srv, http.MethodGet, "/main.dart.wasm", nil)
	if got := asset.Header().Get("Cache-Control"); got != cfg.AssetCacheControl {
		t.Errorf("asset Cache-Control = %q, want %q", got, cfg.AssetCacheControl)
	}

	for _, entry := range []string{"/", "/flutter_service_worker.js"} {
		rec := do(t, srv, http.MethodGet, entry, nil)
		if got := rec.Header().Get("Cache-Control"); got != "no-cache" {
			t.Errorf("%s: Cache-Control = %q, want no-cache", entry, got)
		}
	}
}

func TestBundleWithoutIndexIsRejected(t *testing.T) {
	_, err := NewServer(fstest.MapFS{"main.dart.js": {Data: []byte("x")}}, testConfig(), slog.New(slog.DiscardHandler))

	if err == nil {
		t.Fatal("expected an error for a bundle without index.html")
	}
}

// The image is only useful if the bundle actually made it into the binary.
func TestEmbeddedBundleContainsIndex(t *testing.T) {
	webroot, err := fs.Sub(bundleFS, "webroot")
	if err != nil {
		t.Fatalf("fs.Sub: %v", err)
	}
	if _, err := fs.Stat(webroot, indexFile); err != nil {
		t.Fatalf("embedded bundle has no %s: %v", indexFile, err)
	}
}
