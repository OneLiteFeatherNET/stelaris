// Builds a native Penpot file (.penpot) from the JSON written by
// export_shapes.py: one page per screen group, one board per screen.
import * as penpot from "@penpot/library";
import { createWriteStream, readFileSync } from "fs";
import { Writable } from "stream";

const [src, dest] = process.argv.slice(2);
const boards = JSON.parse(readFileSync(src, "utf8"));

const PAGES = [
  ["0x", "Auth & Projects"],
  ["1x", "Lists & Model dialogs"],
  ["2x", "Detail – Items, Notifications, Fonts"],
  ["3x", "Detail – Sound & Unsaved guard"],
  ["4x", "Settings, Build, Palette & more"],
];
const COLORS = {
  "Primary": "#4C662B", "Primary container": "#DCEBC8", "Secondary container": "#DCE7C8",
  "Chrome (surfaceContainer)": "#EEEFE3", "Surface": "#FFFFFF", "Surface variant": "#F4F4F5",
  "Outline": "#A1A1AA", "On surface": "#18181B", "Muted": "#71717A", "Error": "#B3261E",
  "Note": "#FFF4C2",
};
const COLS = 4, GAP = 160;

const ctx = penpot.createBuildContext();
ctx.addFile({ name: "Stelaris UI – Wireframes" });
for (const [name, color] of Object.entries(COLORS)) {
  ctx.addLibraryColor({ name, color, opacity: 1, path: "Wireframe" });
}

for (const [prefix, pageName] of PAGES) {
  const onPage = boards.filter((b) => b.name[0] === prefix[0]);
  if (!onPage.length) continue;
  ctx.addPage({ name: pageName });
  onPage.forEach((b, i) => {
    const bx = (i % COLS) * (1440 + GAP);
    const by = Math.floor(i / COLS) * (900 + GAP);
    ctx.addBoard({
      name: b.name, x: bx, y: by, width: b.width, height: b.height,
      fills: [{ fillColor: b.fill, fillOpacity: 1 }],
    });
    for (const { kind, ...s } of b.shapes) {
      const shape = { ...s, x: s.x + bx, y: s.y + by };
      if (kind === "path") {
        shape.content = s.content.map((c) => ({
          ...c, params: { x: c.params.x + bx, y: c.params.y + by },
        }));
      }
      try {
        ({ rect: () => ctx.addRect(shape), circle: () => ctx.addCircle(shape),
           path: () => ctx.addPath(shape), text: () => ctx.addText(shape) })[kind]();
      } catch (e) {
        console.error(`${b.name}: ${kind} ${s.name}:`, e.hint ?? e.message, e.explain ?? "");
        process.exit(1);
      }
    }
    ctx.closeBoard();
  });
  ctx.closePage();
}
ctx.closeFile();

await penpot.exportStream(ctx, Writable.toWeb(createWriteStream(dest)));
console.log(`${boards.length} boards -> ${dest}`);
