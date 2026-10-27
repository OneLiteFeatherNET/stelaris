# three.js vendor files

- Source: `three@0.186.1` from npm (`package/build/three.module.js`, `three.core.js`, and `examples/jsm/controls/OrbitControls.js`).
- Minified with esbuild 0.25.0, no bundling: `npx -y esbuild@0.25.0 <input> --minify --format=esm --outfile=<output>`.
- The import in `three.module.min.js` was rewritten with sed from `./three.core.js` to `./three.core.min.js`.
- `OrbitControls.min.js` imports the bare `"three"` specifier, resolved by the import map in `web/index.html`.
- License: see `LICENSE` in this directory.
