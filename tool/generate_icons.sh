#!/usr/bin/env bash
# Builds assets/fonts/StelarisIcons.ttf from the SVGs in design/icons/navigation.
#
# The code points are fixed in tool/icons.fantasticonrc.json, so an icon keeps
# its code point when others are added. A new icon needs an entry there and a
# constant in lib/util/stelaris_icons.dart. Commit the font with the SVGs.
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p assets/fonts
npx --yes fantasticon@3.0.0 --config tool/icons.fantasticonrc.json
