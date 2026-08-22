// Command webserver serves the compiled Stelaris UI web bundle.
//
// It exists so the production image can be built FROM scratch: the bundle is
// embedded into this binary, which is the only file in the image. There is no
// shell, no package manager, no libc and no configuration file to read, so the
// image has no attack surface beyond this program and the Go runtime.
//
// It is intentionally not a web server in the nginx sense. It answers GET and
// HEAD for files that were baked in at build time, and nothing else.
package main

import (
	"context"
	"embed"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

// bundleFS holds the Flutter web build. The checked-in webroot/ is a placeholder
// so the package builds and tests without a Flutter toolchain; the Docker build
// replaces it with the real build/web output before compiling.
//
//go:embed all:webroot
var bundleFS embed.FS

// version is stamped by the Docker build via -ldflags.
var version = "dev"

const (
	// Slowloris protection: a client that cannot send its request headers in
	// ten seconds is not a browser loading a UI.
	readHeaderTimeout = 10 * time.Second
	readTimeout       = 15 * time.Second
	// Generous, because the Wasm bundle is multiple megabytes and mobile
	// connections are slow.
	writeTimeout = 120 * time.Second
	idleTimeout  = 60 * time.Second
	// The default of 1 MiB is pointless for a static bundle.
	maxHeaderBytes = 16 << 10

	shutdownGrace = 10 * time.Second
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
}

func run(args []string) error {
	cfg := LoadConfig(osLookupEnv)

	// The scratch image has no shell and no curl, so the binary doubles as its
	// own health check client: HEALTHCHECK CMD ["/stelaris-ui", "-healthcheck"].
	for _, arg := range args {
		switch arg {
		case "-healthcheck", "--healthcheck":
			return healthcheck(cfg.Addr)
		case "-version", "--version":
			fmt.Println(version)
			return nil
		default:
			return fmt.Errorf("unknown argument %q", arg)
		}
	}

	log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

	webroot, err := fs.Sub(bundleFS, "webroot")
	if err != nil {
		return fmt.Errorf("open embedded bundle: %w", err)
	}

	srv, err := NewServer(webroot, cfg, log)
	if err != nil {
		return fmt.Errorf("index bundle: %w", err)
	}

	httpServer := &http.Server{
		Addr:              cfg.Addr,
		Handler:           srv,
		ReadHeaderTimeout: readHeaderTimeout,
		ReadTimeout:       readTimeout,
		WriteTimeout:      writeTimeout,
		IdleTimeout:       idleTimeout,
		MaxHeaderBytes:    maxHeaderBytes,
		ErrorLog:          slog.NewLogLogger(log.Handler(), slog.LevelWarn),
	}

	listener, err := net.Listen("tcp", cfg.Addr)
	if err != nil {
		return fmt.Errorf("listen on %s: %w", cfg.Addr, err)
	}

	log.Info("stelaris-ui starting",
		slog.String("version", version),
		slog.String("addr", listener.Addr().String()),
		slog.Int("files", len(srv.assets)),
		slog.Bool("cross_origin_isolation", cfg.CrossOriginIsolation),
		slog.Bool("csp", cfg.CSP != ""),
	)
	log.Debug("bundle contents", slog.Any("files", srv.bundleFiles()))

	// This process is PID 1 in the container. Nothing else reaps signals for
	// it, so `docker stop` and Kubernetes pod termination only shut down
	// cleanly because of this.
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	errCh := make(chan error, 1)
	go func() {
		errCh <- httpServer.Serve(listener)
	}()

	select {
	case err := <-errCh:
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			return fmt.Errorf("serve: %w", err)
		}
		return nil
	case <-ctx.Done():
		log.Info("shutdown signal received")
		shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownGrace)
		defer cancel()
		if err := httpServer.Shutdown(shutdownCtx); err != nil {
			return fmt.Errorf("shutdown: %w", err)
		}
		log.Info("stopped")
		return nil
	}
}

// healthcheck talks to the running server over the loopback interface and maps
// the result onto the process exit code Docker expects.
func healthcheck(addr string) error {
	target, err := healthURL(addr)
	if err != nil {
		return err
	}

	client := &http.Client{Timeout: 3 * time.Second}
	resp, err := client.Get(target)
	if err != nil {
		return fmt.Errorf("healthcheck: %w", err)
	}
	defer resp.Body.Close()
	io.Copy(io.Discard, resp.Body)

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("healthcheck: unexpected status %s", resp.Status)
	}
	return nil
}

// healthURL turns a listen address into a loopback URL. A wildcard bind
// (":8080" or "0.0.0.0:8080") is reachable on 127.0.0.1 from inside the
// container, which is where the health check runs.
func healthURL(addr string) (string, error) {
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return "", fmt.Errorf("parse listen address %q: %w", addr, err)
	}
	switch host {
	case "", "0.0.0.0", "[::]", "::":
		host = "127.0.0.1"
	}
	// JoinHostPort brackets IPv6 literals itself.
	return "http://" + net.JoinHostPort(host, port) + healthPath, nil
}
