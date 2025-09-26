import type { GameSummary, ModSummary, GameData, ModManifest } from './types';

const cache = new Map<string, Promise<unknown>>();
const originBase = new URL(import.meta.env.BASE_URL, window.location.origin).toString();

function assetUrl(path: string): string {
  return new URL(path.replace(/^\//, ''), originBase).toString();
}

async function fetchJSON<T>(path: string): Promise<T> {
  const url = assetUrl(path);
  if (!cache.has(url)) {
    cache.set(
      url,
      fetch(url).then(async (response) => {
        if (!response.ok) {
          throw new Error(`Failed to load ${url}: ${response.status}`);
        }
        return (await response.json()) as T;
      }),
    );
  }

  return cache.get(url)! as Promise<T>;
}

async function fetchText(path: string): Promise<string> {
  const url = assetUrl(path);
  if (!cache.has(url)) {
    cache.set(
      url,
      fetch(url).then(async (response) => {
        if (!response.ok) {
          throw new Error(`Failed to load ${url}: ${response.status}`);
        }
        return (await response.text()) as unknown;
      }),
    );
  }
  return cache.get(url)! as Promise<string>;
}

function normalizeStringArray(value: unknown): string[] {
  if (!value) return [];
  if (Array.isArray(value)) {
    return value.map((entry) => String(entry));
  }
  return String(value)
    .split(',')
    .map((entry) => entry.trim())
    .filter(Boolean);
}

export async function getGames(): Promise<GameSummary[]> {
  const raw = await fetchJSON<Record<string, string>>('mods/games.json');
  return Object.entries(raw)
    .map(([id, name]) => ({ id, name }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

export async function getGameData(gameId: string): Promise<GameData> {
  const games = await getGames();
  const game = games.find((g) => g.id === gameId);
  if (!game) {
    throw new Error(`Unknown game id ${gameId}`);
  }

  const modsPath = `mods/${gameId}/mods.json`;
  const rawMods = await fetchJSON<Array<Record<string, unknown>>>(modsPath);

  const mods: ModSummary[] = rawMods.map((mod) => ({
    id: String(mod.id),
    name: String(mod.name),
    shortDesc: String(mod['short-desc'] ?? ''),
    desc: String(mod.desc ?? ''),
    requires: normalizeStringArray(mod.requires),
    authors: normalizeStringArray(mod.authors),
    tags: normalizeStringArray(mod.tags),
    version: String(mod.version ?? '0.0.0'),
  }));

  return { game, mods };
}

export async function getMod(
  gameId: string,
  modId: string,
): Promise<{ data: GameData; mod: ModSummary }>
{
  const data = await getGameData(gameId);
  const mod = data.mods.find((m) => m.id === modId);
  if (!mod) {
    throw new Error(`Unknown mod ${modId} for game ${gameId}`);
  }
  return { data, mod };
}

export async function getModManifest(gameId: string, modId: string): Promise<ModManifest | null> {
  let manifest: ModManifest | null = null;
  let generated: ModManifest | null = null;

  try {
    manifest = await fetchJSON<ModManifest>(`mods/${gameId}/${modId}/manifest.json`);
  } catch (error) {
    console.warn('Manifest missing for', gameId, modId, error);
  }

  try {
    generated = await fetchJSON<ModManifest>(`mods/${gameId}/${modId}/manifest.generated.json`);
  } catch {
    // generated manifest optional
  }

  if (!manifest && !generated) {
    return null;
  }

  return {
    ...manifest,
    download: {
      ...manifest?.download,
      ...generated?.download,
    },
    codeSamples: manifest?.codeSamples,
    images: manifest?.images,
  };
}

export async function getInstallGuide(gameId: string): Promise<string> {
  try {
    return await fetchText(`mods/${gameId}/install.md`);
  } catch {
    return '# Installation Guide\n\nInstructions will be added soon.';
  }
}

export { assetUrl };