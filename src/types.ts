export interface GameSummary {
  id: string;
  name: string;
}

export interface ModSummary {
  id: string;
  name: string;
  shortDesc: string;
  desc: string;
  requires: string[];
  authors: string[];
  tags: string[];
  version: string;
}

export interface ModManifestDownload {
  type?: 'single' | 'archive';
  sources?: string[];
  outputName?: string;
  extension?: string;
  filename?: string;
}

export interface ModManifest {
  download?: ModManifestDownload;
  codeSamples?: Array<{
    path: string;
    label: string;
    language?: string;
  }>;
  images?: Array<{
    path: string;
    alt?: string;
  }>;
}

export interface GameData {
  game: GameSummary;
  mods: ModSummary[];
}