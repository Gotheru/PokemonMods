import { getGames } from '../api';
import { linkTo } from '../navigation';
import { setPageContent, showLoading, showError } from '../render';
import { escapeHTML } from '../utils/html';

export async function renderHome(): Promise<void> {
  showLoading('Loading games...');
  try {
    const games = await getGames();
    const page = document.createElement('div');
    page.className = 'page';
    page.innerHTML = `
      <section class="hero">
        <h1>Pokemon Mods Library</h1>
        <p class="lead">Browse mods for Pokemon fangames. Pick a title to explore its mod catalog. Contact gotheru on Discord if you want your mod to be here :)</p>
      </section>
      <section class="grid" aria-label="Games">
        ${games
          .map(
            (game) => `
            <a class="card card--link" href="${linkTo(`/game/${game.id}`)}">
              <h2>${escapeHTML(game.name)}</h2>
              <p>View available mods and installation steps.</p>
            </a>
          `,
          )
          .join('')}
      </section>
    `;

    setPageContent(page);
    document.title = 'Pokemon Mods Library';
  } catch (error) {
    console.error(error);
    showError('Unable to load games.', error instanceof Error ? error.message : undefined);
  }
}