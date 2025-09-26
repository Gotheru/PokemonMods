#!/usr/bin/env node
import { promises as fs } from 'fs';
import { createWriteStream } from 'fs';
import path from 'path';
import archiver from 'archiver';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');
const modsRoot = path.join(repoRoot, 'public', 'mods');

async function pathExists(target) {
  try {
    await fs.access(target);
    return true;
  } catch {
    return false;
  }
}

async function readJSON(file) {
  const content = await fs.readFile(file, 'utf-8');
  return JSON.parse(content);
}

function normalizeExtension(ext) {
  if (!ext) return '';
  return ext.startsWith('.') ? ext : `.${ext}`;
}

async function ensureDir(dir) {
  await fs.mkdir(dir, { recursive: true });
}

async function clearDirectory(dir) {
  if (!(await pathExists(dir))) {
    return;
  }
  const entries = await fs.readdir(dir);
  await Promise.all(entries.map((entry) => fs.rm(path.join(dir, entry), { recursive: true, force: true })));
}

async function packageSingleFile(modDir, sources, outputName, version, downloadsDir) {
  if (!sources?.length) {
    throw new Error('Single file download requires at least one source');
  }
  const [relativeSource] = sources;
  const absoluteSource = path.join(modDir, relativeSource);
  const sourceInfo = path.parse(relativeSource);
  const ext = sourceInfo.ext || path.parse(absoluteSource).ext;
  if (!ext) {
    throw new Error(`Cannot determine extension for ${relativeSource}`);
  }
  const filename = `${outputName}_${version}${ext}`;
  const destination = path.join(downloadsDir, filename);
  await fs.copyFile(absoluteSource, destination);
  return path.relative(modDir, destination).replace(/\\/g, '/');
}

async function packageArchive(modDir, sources, outputName, version, downloadsDir, extension = '.zip') {
  const normalizedExt = normalizeExtension(extension) || '.zip';
  const filename = `${outputName}_${version}${normalizedExt}`;
  const destination = path.join(downloadsDir, filename);

  const output = createWriteStream(destination);
  const archive = archiver('zip', { zlib: { level: 9 } });

  const promise = new Promise((resolve, reject) => {
    output.on('close', resolve);
    output.on('error', reject);
    archive.on('error', reject);
  });

  archive.pipe(output);

  const items = sources?.length ? sources : ['.'];
  for (const item of items) {
    const absoluteItem = path.join(modDir, item);
    const stats = await fs.stat(absoluteItem);
    if (stats.isDirectory()) {
      archive.directory(absoluteItem, path.basename(item));
    } else {
      archive.file(absoluteItem, { name: path.basename(item) });
    }
  }

  await archive.finalize();
  await promise;
  return path.relative(modDir, destination).replace(/\\/g, '/');
}

async function writeGeneratedManifest(modDir, data) {
  const target = path.join(modDir, 'manifest.generated.json');
  await fs.writeFile(target, `${JSON.stringify(data, null, 2)}\n`, 'utf-8');
}

async function packageMods() {
  if (!(await pathExists(modsRoot))) {
    console.warn('No mods directory found; skipping packaging.');
    return;
  }

  const games = await fs.readdir(modsRoot, { withFileTypes: true });
  for (const gameEntry of games) {
    if (!gameEntry.isDirectory()) continue;
    const gameId = gameEntry.name;
    const gameDir = path.join(modsRoot, gameId);
    const modsFile = path.join(gameDir, 'mods.json');
    if (!(await pathExists(modsFile))) continue;

    const modsList = await readJSON(modsFile);
    for (const mod of modsList) {
      const modId = String(mod.id);
      const version = String(mod.version ?? '').trim();
      if (!version) {
        console.warn(`Skipping ${gameId}/${modId}: missing version.`);
        continue;
      }
      const modDir = path.join(gameDir, modId);
      const manifestPath = path.join(modDir, 'manifest.json');
      if (!(await pathExists(manifestPath))) {
        console.warn(`Skipping ${gameId}/${modId}: missing manifest.json`);
        continue;
      }
      const manifest = await readJSON(manifestPath);
      const download = manifest.download;
      if (!download) {
        console.warn(`Skipping ${gameId}/${modId}: manifest missing download section.`);
        continue;
      }

      const downloadsDir = path.join(modDir, 'downloads');
      await ensureDir(downloadsDir);
      await clearDirectory(downloadsDir);

      const outputName = download.outputName ?? modId;
      let filename;
      if (download.type === 'single') {
        filename = await packageSingleFile(modDir, download.sources, outputName, version, downloadsDir);
      } else {
        filename = await packageArchive(
          modDir,
          download.sources,
          outputName,
          version,
          downloadsDir,
          download.extension,
        );
      }

      await writeGeneratedManifest(modDir, {
        download: {
          filename,
        },
      });
    }
  }
}

packageMods().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});