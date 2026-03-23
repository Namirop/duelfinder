/**
 * make_square_icon.js — Crée une version carrée du logo pour flutter_launcher_icons
 * Le logo original est 1536x1024 (ratio 3:2), ce qui cause un étirement vertical
 * dans les icônes. Ce script centre le logo sur un canvas carré transparent.
 *
 * Run: node scripts/make_square_icon.js
 */

import { Jimp } from 'jimp';
import path from 'path';
import { fileURLToPath } from 'url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));

const INPUT  = path.resolve('..', 'app', 'assets', 'images', 'logo.png');
const OUTPUT = path.resolve('..', 'app', 'assets', 'images', 'logo_icon.png');

async function main() {
  const logo = await Jimp.read(INPUT);
  const { width, height } = logo.bitmap;

  // Canvas carré 1024×1024 (taille standard pour les icônes)
  const CANVAS = 1024;
  // Le logo occupe 60% du canvas pour rester dans la safe zone Android adaptive
  const targetWidth  = Math.floor(CANVAS * 0.60);
  const targetHeight = Math.floor(height * (targetWidth / width));

  logo.resize({ w: targetWidth, h: targetHeight });

  const xOffset = Math.floor((CANVAS - targetWidth)  / 2);
  const yOffset = Math.floor((CANVAS - targetHeight) / 2);

  const canvas = new Jimp({ width: CANVAS, height: CANVAS, color: 0x00000000 });
  canvas.composite(logo, xOffset, yOffset);
  await canvas.write(OUTPUT);

  console.log(`✓  logo_icon.png créé : ${CANVAS}x${CANVAS}px`);
  console.log(`   logo redimensionné : ${targetWidth}x${targetHeight}px (60% du canvas)`);
  console.log(`   position : x=${xOffset}, y=${yOffset}`);
}

main().catch(e => { console.error(e); process.exit(1); });
