// three.js bridge for the asset preview (Flutter web).
//
// Dart reads the model and sends a scene (see lib/feature/asset/preview):
//   { textures: [{id, dataUri, width, height}],
//     levels: [{boxes}, {boxes}, {boxes}],   // 0 full, 1 reduced, 2 box
//     unsupported: [...] }                    // shown by Dart only
// Boxes are in Minecraft model units (0..16 per block axis). This file only
// draws them: it merges faces into one geometry per texture and level, and
// wraps the levels in a THREE.LOD.

import * as THREE from 'three';
import { OrbitControls } from './vendor/three/OrbitControls.js';

const LOD_DISTANCES = [0, 1.5, 3];
const CHECKER = 'checker';
const FOV_DEGREES = 40;
const GREY = 0x808080;

// Face frames as seen from outside the box with +Y up: the outward normal
// N, the texture's right direction R and its top direction U. Each entry is
// [axis, sign] with axis 0 = x, 1 = y, 2 = z.
const FACES = {
    north: { n: [2, -1], r: [0, -1], u: [1, 1] },
    south: { n: [2, 1], r: [0, 1], u: [1, 1] },
    east: { n: [0, 1], r: [2, -1], u: [1, 1] },
    west: { n: [0, -1], r: [2, 1], u: [1, 1] },
    up: { n: [1, 1], r: [0, 1], u: [2, -1] },
    down: { n: [1, -1], r: [0, 1], u: [2, 1] },
};

// Corner order of a face: top-left, top-right, bottom-right, bottom-left.
const CORNERS = [[-1, 1], [1, 1], [1, -1], [-1, -1]];

// Returns the four corners, normal and UVs of one face, transformed by the
// box rotation. Corner coordinates are Minecraft units around the origin.
function faceQuad(box, face, rotation, transform) {
    const corners = CORNERS.map(([r, u]) => {
        const p = [0, 0, 0];
        p[face.n[0]] = face.n[1] > 0 ? box.to[face.n[0]] : box.from[face.n[0]];
        p[face.r[0]] = r * face.r[1] > 0 ? box.to[face.r[0]] : box.from[face.r[0]];
        p[face.u[0]] = u * face.u[1] > 0 ? box.to[face.u[0]] : box.from[face.u[0]];
        return transform ? transform(p) : p;
    });
    const normal = [0, 0, 0];
    normal[face.n[0]] = face.n[1];
    const n = transform ? transform(normal, true) : normal;
    // Rotating the texture clockwise moves each corner's UV one step right.
    const steps = ((rotation || 0) / 90) % 4;
    return { corners, normal: n, steps };
}

// Builds the box transform: Euler 'ZYX' in degrees around the origin,
// optionally with Minecraft's rescale of the two non-rotated axes.
function makeTransform(rot) {
    if (!rot) return null;
    const angles = rot.angles.map((a) => (a * Math.PI) / 180);
    const euler = new THREE.Euler(angles[0], angles[1], angles[2], 'ZYX');
    const scale = [1, 1, 1];
    const active = angles.map((a, i) => (a !== 0 ? i : -1)).filter((i) => i >= 0);
    if (rot.rescale && active.length === 1) {
        const s = 1 / Math.cos(angles[active[0]]);
        for (let i = 0; i < 3; i++) if (i !== active[0]) scale[i] = s;
    }
    const origin = rot.origin;
    return (p, isNormal = false) => {
        const v = new THREE.Vector3(...p);
        if (isNormal) return v.applyEuler(euler).toArray();
        v.set(
            origin[0] + (p[0] - origin[0]) * scale[0],
            origin[1] + (p[1] - origin[1]) * scale[1],
            origin[2] + (p[2] - origin[2]) * scale[2],
        );
        v.sub(new THREE.Vector3(...origin)).applyEuler(euler).add(new THREE.Vector3(...origin));
        return v.toArray();
    };
}

// Turns the boxes of one level into quads, each with a material key.
function quadsOf(boxes, textures) {
    const quads = [];
    for (const box of boxes) {
        const transform = makeTransform(box.rotation);
        for (const [name, face] of Object.entries(box.faces || {})) {
            const frame = FACES[name];
            if (!frame) continue;
            const q = faceQuad(box, frame, face.rotation, transform);
            const tex = face.texture != null && textures.has(face.texture) ? face.texture : null;
            let key = CHECKER;
            if (tex != null) key = face.averageColor ? `avg:${tex}` : `tex:${tex}`;
            const [u1, v1, u2, v2] = face.uv || [0, 0, 16, 16];
            // Texture coordinates per corner; v is flipped into three's space.
            const uvs = CORNERS.map(([r, u]) => [
                (r < 0 ? u1 : u2) / 16,
                1 - (u > 0 ? v1 : v2) / 16,
            ]);
            const rotated = q.corners.map((_, j) => uvs[(j - q.steps + 4) % 4]);
            quads.push({ corners: q.corners, normal: q.normal, uvs: rotated, key });
        }
    }
    return quads;
}

// Merges quads into one mesh per material key.
function buildLevel(quads, offset, materialFor) {
    const merged = new Map();
    for (const q of quads) {
        let g = merged.get(q.key);
        if (!g) {
            g = { pos: [], nor: [], uv: [], idx: [] };
            merged.set(q.key, g);
        }
        const base = g.pos.length / 3;
        q.corners.forEach((p, j) => {
            g.pos.push(p[0] - offset[0], p[1] - offset[1], p[2] - offset[2]);
            g.nor.push(...q.normal);
            g.uv.push(...q.uvs[j]);
        });
        g.idx.push(base, base + 1, base + 2, base, base + 2, base + 3);
    }
    const group = new THREE.Group();
    for (const [key, g] of merged) {
        const geometry = new THREE.BufferGeometry();
        geometry.setAttribute('position', new THREE.Float32BufferAttribute(g.pos, 3));
        geometry.setAttribute('normal', new THREE.Float32BufferAttribute(g.nor, 3));
        geometry.setAttribute('uv', new THREE.Float32BufferAttribute(g.uv, 2));
        geometry.setIndex(g.idx);
        group.add(new THREE.Mesh(geometry, materialFor(key)));
    }
    return group;
}

// Average of the opaque pixels, in sRGB. Returns null when there are none.
function averageOpaqueColor(image) {
    const canvas = document.createElement('canvas');
    canvas.width = image.width;
    canvas.height = image.height;
    const ctx = canvas.getContext('2d', { willReadFrequently: true });
    ctx.drawImage(image, 0, 0);
    const data = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    let r = 0, g = 0, b = 0, n = 0;
    for (let i = 0; i < data.length; i += 4) {
        if (data[i + 3] < 128) continue;
        r += data[i];
        g += data[i + 1];
        b += data[i + 2];
        n++;
    }
    if (n === 0) return null;
    return new THREE.Color().setRGB(r / n / 255, g / n / 255, b / n / 255, THREE.SRGBColorSpace);
}

// The 2x2 magenta and black checker for missing textures.
function makeChecker() {
    const data = new Uint8Array([
        255, 0, 255, 255, 0, 0, 0, 255,
        0, 0, 0, 255, 255, 0, 255, 255,
    ]);
    const texture = new THREE.DataTexture(data, 2, 2);
    texture.magFilter = THREE.NearestFilter;
    texture.minFilter = THREE.NearestFilter;
    texture.generateMipmaps = false;
    texture.colorSpace = THREE.SRGBColorSpace;
    texture.needsUpdate = true;
    return texture;
}

function mount(element, scene) {
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    const canvas = renderer.domElement;
    canvas.style.display = 'block';
    canvas.style.width = '100%';
    canvas.style.height = '100%';
    canvas.style.touchAction = 'none';
    // Keep wheel and pointer gestures inside the preview, so the page does not scroll.
    for (const type of ['wheel', 'pointerdown', 'pointermove', 'pointerup', 'pointercancel']) {
        canvas.addEventListener(type, (e) => e.stopPropagation());
    }
    element.appendChild(canvas);

    const threeScene = new THREE.Scene();
    threeScene.add(new THREE.AmbientLight(0xffffff, 0.6));
    const sun = new THREE.DirectionalLight(0xffffff, 1.0);
    sun.position.set(1, 2, 1.5);
    threeScene.add(sun);

    const camera = new THREE.PerspectiveCamera(FOV_DEGREES, 1, 0.1, 1000);
    const controls = new OrbitControls(camera, canvas);
    controls.enableDamping = true;
    controls.autoRotate = false;
    controls.autoRotateSpeed = 2;

    // Textures: nearest filtering keeps pixel art sharp.
    const checker = makeChecker();
    const textures = new Map();
    const materials = new Map();
    const loader = new THREE.TextureLoader();
    for (const t of scene.textures || []) {
        const texture = loader.load(t.dataUri, (loaded) => {
            // Once the image is known, the average colour of box faces is known too.
            const average = averageOpaqueColor(loaded.image);
            if (average) materials.get(`avg:${t.id}`)?.color.copy(average);
        });
        texture.magFilter = THREE.NearestFilter;
        texture.minFilter = THREE.NearestFilter;
        texture.generateMipmaps = false;
        texture.colorSpace = THREE.SRGBColorSpace;
        textures.set(t.id, texture);
    }

    const materialFor = (key) => {
        let material = materials.get(key);
        if (material) return material;
        const common = { alphaTest: 0.1, side: THREE.DoubleSide, transparent: false };
        if (key === CHECKER) {
            material = new THREE.MeshLambertMaterial({ map: checker, ...common });
        } else if (key.startsWith('avg:')) {
            material = new THREE.MeshLambertMaterial({ color: GREY, ...common });
        } else {
            material = new THREE.MeshLambertMaterial({ map: textures.get(key.slice(4)), ...common });
        }
        materials.set(key, material);
        return material;
    };

    // Bounds are taken from the full level and the model is centred on them.
    const levels = [0, 1, 2].map((i) => scene.levels?.[i]?.boxes || []);
    const quadsByLevel = levels.map((boxes) => quadsOf(boxes, textures));
    const bounds = new THREE.Box3();
    for (const quad of quadsByLevel[0].length ? quadsByLevel[0] : quadsByLevel.flat()) {
        for (const p of quad.corners) bounds.expandByPoint(new THREE.Vector3(...p));
    }
    if (bounds.isEmpty()) bounds.set(new THREE.Vector3(-8, -8, -8), new THREE.Vector3(8, 8, 8));
    const centre = bounds.getCenter(new THREE.Vector3());
    const size = bounds.getSize(new THREE.Vector3());
    const offset = centre.toArray();

    // Frame the bounds: the distance at which the bounding sphere fits the view.
    const radius = Math.max(size.length() / 2, 1);
    const distance = (radius / Math.sin((FOV_DEGREES * Math.PI) / 360)) * 1.1;

    // Level distances are multiples of the framing distance, so a large model
    // still opens in full detail.
    const lod = new THREE.LOD();
    quadsByLevel.forEach((quads, i) => {
        lod.addLevel(buildLevel(quads, offset, materialFor), LOD_DISTANCES[i] * distance);
    });
    threeScene.add(lod);
    const homeOffset = new THREE.Vector3(0.7, 0.5, 1).normalize().multiplyScalar(distance);
    camera.far = Math.max(1000, distance * 10);
    controls.minDistance = radius * 0.5;
    controls.maxDistance = distance * 6;
    const resetView = () => {
        camera.position.copy(homeOffset);
        controls.target.set(0, 0, 0);
        controls.update();
    };
    resetView();

    const resize = () => {
        const width = Math.max(element.clientWidth, 1);
        const height = Math.max(element.clientHeight, 1);
        renderer.setSize(width, height, false);
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
    };
    const observer = new ResizeObserver(resize);
    observer.observe(element);
    resize();

    renderer.setAnimationLoop(() => {
        controls.update();
        renderer.render(threeScene, camera);
    });

    return {
        // level: 0 full, 1 reduced, 2 box; null restores the automatic LOD.
        setDetail(level) {
            if (level == null) {
                lod.autoUpdate = true;
                return;
            }
            lod.autoUpdate = false;
            lod.levels.forEach((entry, i) => {
                entry.object.visible = i === level;
            });
        },
        setAutoRotate(enabled) {
            controls.autoRotate = !!enabled;
        },
        resetView,
        dispose() {
            renderer.setAnimationLoop(null);
            observer.disconnect();
            controls.dispose();
            threeScene.traverse((object) => {
                if (object.geometry) object.geometry.dispose();
            });
            for (const material of materials.values()) material.dispose();
            for (const texture of textures.values()) texture.dispose();
            checker.dispose();
            renderer.dispose();
            renderer.forceContextLoss();
            canvas.remove();
        },
    };
}

window.stelarisAssetViewer = { mount };
window.stelarisAssetViewerReady = Promise.resolve(true);
