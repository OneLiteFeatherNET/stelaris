package main

import (
	"os"
	"strconv"
	"strings"
)

// Config is the full runtime surface of the server. Everything is read from the
// environment once at startup so the container can stay immutable: there is no
// config file to mount, and therefore no file the container needs to read.
type Config struct {
	// Addr is the listen address. The default port is above 1024 so the process
	// can run as an unprivileged user without CAP_NET_BIND_SERVICE.
	Addr string

	// CSP is the Content-Security-Policy sent with every response. Empty means
	// the header is omitted entirely.
	CSP string

	// CrossOriginIsolation enables COOP/COEP, which lets the Wasm renderer use
	// SharedArrayBuffer and render on multiple threads. Off by default: it is a
	// performance opt-in, and cross-origin isolation breaks any cross-origin
	// resource that does not opt in via CORP/CORS.
	CrossOriginIsolation bool

	// COEP is the Cross-Origin-Embedder-Policy value used when
	// CrossOriginIsolation is on. "credentialless" is the friendlier of the two
	// valid values because cross-origin resources do not have to send CORP.
	COEP string

	// AssetCacheControl is the Cache-Control value for bundle files that are not
	// entry points. Flutter does not put content hashes in its output file names
	// (main.dart.wasm keeps its name across builds), so the default revalidates
	// instead of pinning clients to a build that no longer exists on the server.
	AssetCacheControl string

	// AccessLog toggles the one-line-per-request JSON log on stdout.
	AccessLog bool
}

// defaultCSP is deliberately not the strictest policy that a browser accepts,
// but the strictest one a Flutter web bundle actually runs under:
//   - 'unsafe-inline' for scripts: web/index.html carries inline bootstrap and
//     theme-preload scripts, and Flutter's loader does not support CSP nonces
//     (flutter/flutter#167800).
//   - 'unsafe-eval' and 'wasm-unsafe-eval': CanvasKit and the Wasm entrypoint
//     compile code at runtime (flutter/flutter#127658). A build produced with
//     `flutter build web --csp` can drop 'unsafe-eval'.
//   - blob: for scripts and workers: the engine spawns its web workers from
//     blob URLs.
//
// %s is the connect-src value, which is the one directive that depends on the
// deployment (it has to allow the Stelaris backend).
const defaultCSP = "default-src 'self'; " +
	"base-uri 'self'; " +
	"object-src 'none'; " +
	"frame-ancestors 'none'; " +
	"form-action 'none'; " +
	"script-src 'self' 'unsafe-inline' 'unsafe-eval' 'wasm-unsafe-eval' blob:; " +
	"style-src 'self' 'unsafe-inline'; " +
	"img-src 'self' data: blob:; " +
	"font-src 'self' data:; " +
	"media-src 'self' data: blob:; " +
	"worker-src 'self' blob:; " +
	"manifest-src 'self'; " +
	"connect-src %s"

// LoadConfig builds a Config from environment variables. lookup is normally
// os.LookupEnv; tests pass their own.
func LoadConfig(lookup func(string) (string, bool)) Config {
	cfg := Config{
		Addr:                 envString(lookup, "STELARIS_ADDR", ":8080"),
		CrossOriginIsolation: envBool(lookup, "STELARIS_CROSS_ORIGIN_ISOLATION", false),
		COEP:                 envString(lookup, "STELARIS_COEP", "credentialless"),
		AssetCacheControl:    envString(lookup, "STELARIS_ASSET_CACHE_CONTROL", "no-cache"),
		AccessLog:            envBool(lookup, "STELARIS_ACCESS_LOG", true),
	}

	// An explicitly set STELARIS_CSP always wins, including an empty value,
	// which is how an operator turns the header off.
	if csp, ok := lookup("STELARIS_CSP"); ok {
		cfg.CSP = strings.TrimSpace(csp)
	} else {
		connectSrc := envString(lookup, "STELARIS_CONNECT_SRC", "'self' https:")
		cfg.CSP = strings.Replace(defaultCSP, "%s", connectSrc, 1)
	}

	if cfg.COEP != "require-corp" {
		cfg.COEP = "credentialless"
	}

	return cfg
}

func envString(lookup func(string) (string, bool), key, fallback string) string {
	if v, ok := lookup(key); ok {
		if trimmed := strings.TrimSpace(v); trimmed != "" {
			return trimmed
		}
	}
	return fallback
}

func envBool(lookup func(string) (string, bool), key string, fallback bool) bool {
	v, ok := lookup(key)
	if !ok {
		return fallback
	}
	parsed, err := strconv.ParseBool(strings.TrimSpace(v))
	if err != nil {
		return fallback
	}
	return parsed
}

// osLookupEnv is the production lookup function.
func osLookupEnv(key string) (string, bool) { return os.LookupEnv(key) }
