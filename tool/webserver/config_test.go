package main

import (
	"strings"
	"testing"
)

func lookupFrom(env map[string]string) func(string) (string, bool) {
	return func(key string) (string, bool) {
		v, ok := env[key]
		return v, ok
	}
}

func TestConfigDefaults(t *testing.T) {
	cfg := LoadConfig(lookupFrom(nil))

	if cfg.Addr != ":8080" {
		t.Errorf("Addr = %q, want :8080 (unprivileged port)", cfg.Addr)
	}
	if cfg.CrossOriginIsolation {
		t.Error("cross-origin isolation must be opt-in")
	}
	if cfg.AssetCacheControl != "no-cache" {
		t.Errorf("AssetCacheControl = %q, want no-cache", cfg.AssetCacheControl)
	}
	if !cfg.AccessLog {
		t.Error("access log should default to on")
	}
	if !strings.Contains(cfg.CSP, "connect-src 'self' https:") {
		t.Errorf("default CSP connect-src is wrong: %s", cfg.CSP)
	}
}

func TestConnectSrcOverride(t *testing.T) {
	cfg := LoadConfig(lookupFrom(map[string]string{
		"STELARIS_CONNECT_SRC": "'self' https://api.stelaris.example",
	}))

	if !strings.Contains(cfg.CSP, "connect-src 'self' https://api.stelaris.example") {
		t.Errorf("connect-src not applied: %s", cfg.CSP)
	}
	if strings.Contains(cfg.CSP, "%s") {
		t.Errorf("CSP placeholder left in output: %s", cfg.CSP)
	}
}

// The policy is derived from the configured backends so the two cannot drift
// apart - a backend the app may not call is a very quiet failure.
func TestConnectSrcFollowsConfiguredBackends(t *testing.T) {
	cfg := LoadConfig(lookupFrom(map[string]string{
		"STELARIS_BACKEND_URL":   "https://api.stelaris.example/v1",
		"STELARIS_GENERATOR_URL": "https://generator.stelaris.example",
	}))

	// The path is dropped: CSP matches origins.
	want := "connect-src 'self' https://api.stelaris.example https://generator.stelaris.example"
	if !strings.Contains(cfg.CSP, want) {
		t.Errorf("CSP = %s, want it to contain %q", cfg.CSP, want)
	}
}

func TestConnectSrcDeduplicatesAndIgnoresJunk(t *testing.T) {
	cfg := LoadConfig(lookupFrom(map[string]string{
		"STELARIS_BACKEND_URL":   "https://api.stelaris.example/a",
		"STELARIS_GENERATOR_URL": "https://api.stelaris.example/b",
	}))
	if strings.Count(cfg.CSP, "https://api.stelaris.example") != 1 {
		t.Errorf("origin repeated: %s", cfg.CSP)
	}

	// A value that is not an http(s) URL must not be injected into the header.
	cfg = LoadConfig(lookupFrom(map[string]string{"STELARIS_BACKEND_URL": "javascript:alert(1)"}))
	if strings.Contains(cfg.CSP, "javascript:") {
		t.Errorf("junk leaked into the policy: %s", cfg.CSP)
	}
	if !strings.Contains(cfg.CSP, "connect-src 'self' https:") {
		t.Errorf("expected the fallback connect-src, got: %s", cfg.CSP)
	}
}

func TestExplicitConnectSrcOverridesDerivedOne(t *testing.T) {
	cfg := LoadConfig(lookupFrom(map[string]string{
		"STELARIS_BACKEND_URL": "https://api.stelaris.example",
		"STELARIS_CONNECT_SRC": "'self' https://proxy.example",
	}))

	if !strings.Contains(cfg.CSP, "connect-src 'self' https://proxy.example") {
		t.Errorf("explicit connect-src ignored: %s", cfg.CSP)
	}
}

func TestExplicitCSPWins(t *testing.T) {
	cfg := LoadConfig(lookupFrom(map[string]string{
		"STELARIS_CSP":         "default-src 'none'",
		"STELARIS_CONNECT_SRC": "'self'",
	}))

	if cfg.CSP != "default-src 'none'" {
		t.Errorf("CSP = %q", cfg.CSP)
	}
}

// An empty STELARIS_CSP is how an operator turns the header off, which has to be
// distinguishable from "not set".
func TestEmptyCSPDisablesHeader(t *testing.T) {
	cfg := LoadConfig(lookupFrom(map[string]string{"STELARIS_CSP": ""}))

	if cfg.CSP != "" {
		t.Errorf("CSP = %q, want empty", cfg.CSP)
	}
}

func TestCOEPFallsBackToCredentialless(t *testing.T) {
	if got := LoadConfig(lookupFrom(map[string]string{"STELARIS_COEP": "require-corp"})).COEP; got != "require-corp" {
		t.Errorf("COEP = %q", got)
	}
	if got := LoadConfig(lookupFrom(map[string]string{"STELARIS_COEP": "nonsense"})).COEP; got != "credentialless" {
		t.Errorf("COEP = %q, want credentialless for an invalid value", got)
	}
}

func TestBoolParsing(t *testing.T) {
	cases := map[string]bool{"true": true, "1": true, "false": false, "0": false}
	for value, want := range cases {
		cfg := LoadConfig(lookupFrom(map[string]string{"STELARIS_CROSS_ORIGIN_ISOLATION": value}))
		if cfg.CrossOriginIsolation != want {
			t.Errorf("%q -> %v, want %v", value, cfg.CrossOriginIsolation, want)
		}
	}
	// Garbage must not silently flip a security-relevant setting.
	if LoadConfig(lookupFrom(map[string]string{"STELARIS_ACCESS_LOG": "maybe"})).AccessLog != true {
		t.Error("invalid bool should fall back to the default")
	}
}

func TestHealthURL(t *testing.T) {
	cases := map[string]string{
		":8080":          "http://127.0.0.1:8080/healthz",
		"0.0.0.0:8080":   "http://127.0.0.1:8080/healthz",
		"127.0.0.1:9000": "http://127.0.0.1:9000/healthz",
		"[::]:8080":      "http://127.0.0.1:8080/healthz",
		"[::1]:8080":     "http://[::1]:8080/healthz",
	}
	for addr, want := range cases {
		got, err := healthURL(addr)
		if err != nil {
			t.Errorf("%s: %v", addr, err)
			continue
		}
		if got != want {
			t.Errorf("%s -> %s, want %s", addr, got, want)
		}
	}

	if _, err := healthURL("not-an-address"); err == nil {
		t.Error("expected an error for a malformed listen address")
	}
}
