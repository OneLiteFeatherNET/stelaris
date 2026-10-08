// Builds a native Penpot file (.penpot) from the JSON written by
// export_shapes.py: one page with one board per screen, the M3 colour
// scheme as library colours (shapes reference them) and transparent
// hotspots with prototype interactions, so the page works as a click dummy.
import * as penpot from "@penpot/library";
import { createWriteStream, readFileSync, writeFileSync } from "fs";
import { Writable } from "stream";

const [src, dest, flowsOut] = process.argv.slice(2);
const { colors, boards } = JSON.parse(readFileSync(src, "utf8"));

const GROUPS = [
  ["0", "Auth & Projects"], ["1", "Lists"], ["2", "Detail – Items, Notifications, Fonts"],
  ["3", "Detail – Sound & Unsaved guard"], ["4", "Settings, Build, Palette & more"],
  ["5", "Model dialogs"],
];
const FLOWS = [["Sign in → Projects → App", "01"], ["App: Items", "10"]];
const COLS = 5, GAP = 160, LABEL = 140;

const ctx = penpot.createBuildContext();
ctx.addFile({ name: "Stelaris UI – Click-Dummy" });
const fileId = ctx.currentFileId;

// Library colours; shapes whose hex matches a role reference it.
const colorRef = {};
for (const [role, hex] of Object.entries({ ...colors, note: "#FFF4C2" })) {
  const id = ctx.addLibraryColor({
    name: role, color: hex, opacity: 1, path: role === "note" ? "Wireframe" : "M3 Light",
  });
  colorRef[hex.toUpperCase()] ??= id;
}
const withRef = (fills) => fills.map((f) => {
  const id = colorRef[f.fillColor.toUpperCase()];
  return id ? { ...f, fillColorRefId: id, fillColorRefFile: fileId } : f;
});
const withStrokeRef = (strokes) => strokes.map((s) => {
  const id = colorRef[s.strokeColor.toUpperCase()];
  return id ? { ...s, strokeColorRefId: id, strokeColorRefFile: fileId } : s;
});

const pageId = ctx.addPage({ name: "Click-Dummy" });
const boardId = Object.fromEntries(boards.map((b) => [b.key, ctx.genId()]));

const text = (x, y, s, size) => ctx.addText({
  name: s, x, y, width: s.length * size * 0.6, height: size * 1.25, growType: "auto-width",
  content: { type: "root", children: [{ type: "paragraph-set", children: [{ type: "paragraph",
    children: [{ text: s, fontId: "gfont-work-sans", fontFamily: "Work Sans",
      fontVariantId: "700", fontWeight: "700", fontStyle: "normal", fontSize: String(size),
      fills: withRef([{ fillColor: colors.onSurface, fillOpacity: 1 }]) }] }] }] },
});

let y0 = 0;
for (const [digit, groupName] of GROUPS) {
  const group = boards.filter((b) => b.key[0] === digit);
  if (!group.length) continue;
  text(0, y0, groupName, 56);
  y0 += LABEL;
  group.forEach((b, i) => {
    const bx = (i % COLS) * (1440 + GAP);
    const by = y0 + Math.floor(i / COLS) * (900 + GAP + 60);
    ctx.addBoard({
      id: boardId[b.key], name: b.name, x: bx, y: by, width: b.width, height: b.height,
      fills: withRef([{ fillColor: b.fill, fillOpacity: 1 }]),
    });
    for (const { kind, ...s } of b.shapes) {
      const shape = { ...s, x: s.x + bx, y: s.y + by };
      if (shape.fills) shape.fills = withRef(shape.fills);
      if (shape.strokes) shape.strokes = withStrokeRef(shape.strokes);
      if (kind === "path") {
        shape.content = s.content.map((c) => ({
          ...c, params: { x: c.params.x + bx, y: c.params.y + by },
        }));
      }
      if (kind === "text") {
        const leaf = shape.content.children[0].children[0].children[0];
        leaf.fills = withRef(leaf.fills);
      }
      add(kind, shape, b.name);
    }
    // Hotspots last, so they sit on top of everything they cover.
    for (const l of b.links) {
      const back = l.target === "back";
      add("rect", {
        name: back ? "hotspot ← back" : `hotspot → ${l.target}`,
        x: l.x + bx, y: l.y + by, width: l.w, height: l.h,
        fills: [{ fillColor: "#FFFFFF", fillOpacity: 0 }],
        interactions: [back
          ? { eventType: "click", actionType: "prev-screen" }
          : { eventType: "click", actionType: "navigate", destination: boardId[l.target],
              preserveScroll: false,
              animation: { animationType: "dissolve", duration: 150, easing: "ease-out" } }],
      }, b.name);
    }
    ctx.closeBoard();
  });
  y0 += Math.ceil(group.length / COLS) * (900 + GAP + 60) + 200;
}
ctx.closePage();
ctx.closeFile();

function add(kind, shape, board) {
  try {
    ({ rect: () => ctx.addRect(shape), circle: () => ctx.addCircle(shape),
       path: () => ctx.addPath(shape), text: () => ctx.addText(shape) })[kind]();
  } catch (e) {
    console.error(`${board}: ${kind} ${shape.name}:`, e.hint ?? e.message,
                  JSON.stringify(e.explain ?? ""));
    process.exit(1);
  }
}

await penpot.exportStream(ctx, Writable.toWeb(createWriteStream(dest)));
// The builder API has no flows; patch_flows.py adds them to the page.
writeFileSync(flowsOut, JSON.stringify({
  fileId, pageId,
  flows: FLOWS.map(([name, key]) => ({ id: ctx.genId(), name, startingFrame: boardId[key] })),
}));
console.log(`${boards.length} boards -> ${dest}`);
