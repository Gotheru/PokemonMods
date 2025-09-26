import 'highlight.js/styles/github-dark.css';
import './style.css';

import { Router } from './router';
import { showError } from './render';
import { renderGame } from './views/game';
import { renderHome } from './views/home';
import { renderInstall } from './views/install';
import { renderMod } from './views/mod';

const basePath = import.meta.env.BASE_URL;

const router = new Router(
  [
    { pattern: /^\/$/, handler: () => renderHome() },
    { pattern: /^\/game\/([^/]+)\/?$/, handler: ([gameId]) => renderGame(gameId) },
    { pattern: /^\/game\/([^/]+)\/install\/?$/, handler: ([gameId]) => renderInstall(gameId) },
    { pattern: /^\/game\/([^/]+)\/mod\/([^/]+)\/?$/, handler: ([gameId, modId]) => renderMod(gameId, modId) },
  ],
  () => showError('Page not found'),
  basePath,
);

router.start();
