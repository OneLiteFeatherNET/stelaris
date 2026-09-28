#!/usr/bin/env bash
# Rasterises web/icons/*.png and web/favicon.png from the SVGs in
# design/icons/app. Edit the SVGs, then rerun this script to regenerate
# every PNG; commit both the SVGs and the PNGs.
set -euo pipefail

cd "$(dirname "$0")/.."

SRC=design/icons/app
OUT=web/icons

mkdir -p "$OUT"

rsvg-convert -w 192 -h 192 "$SRC/stelaris.svg" -o "$OUT/Icon-192.png"
rsvg-convert -w 512 -h 512 "$SRC/stelaris.svg" -o "$OUT/Icon-512.png"

rsvg-convert -w 192 -h 192 "$SRC/stelaris_maskable.svg" -o "$OUT/Icon-maskable-192.png"
rsvg-convert -w 512 -h 512 "$SRC/stelaris_maskable.svg" -o "$OUT/Icon-maskable-512.png"

rsvg-convert -w 512 -h 512 "$SRC/stelaris_monochrome.svg" -o "$OUT/Icon-monochrome-512.png"

rsvg-convert -w 32 -h 32 "$SRC/favicon.svg" -o web/favicon.png
cp "$SRC/favicon.svg" web/favicon.svg
