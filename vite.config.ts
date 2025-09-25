import { defineConfig } from 'vite';

// Match GitHub Pages path when building while using root during local dev
export default defineConfig(({ command }) => ({
  base: command === 'build' ? '/PokemonMods/' : '/',
  server: {
    port: 4322,
  },
}));