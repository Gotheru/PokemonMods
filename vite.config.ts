import { defineConfig } from 'vite';

// Match GitHub Pages path when building while using root during local dev
export default defineConfig(({ command }) => {
  const cacheTag =
    command === 'build'
      ? process.env.GITHUB_RUN_ID ?? process.env.VITE_BUILD_ID ?? Date.now().toString()
      : 'dev';
  return {
    base: command === 'build' ? '/PokemonMods/' : '/',
    define: {
      __ASSET_BUST__: JSON.stringify(cacheTag),
    },
    server: {
      port: 4322,
    },
  };
});

