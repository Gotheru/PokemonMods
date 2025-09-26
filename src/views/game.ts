import { getGameData } from '../api';
import { linkTo } from '../navigation';
import type { ModSummary } from '../types';
import { setPageContent, showLoading, showError } from '../render';
import { escapeHTML, formatInlineCode } from '../utils/html';

function uniqueSorted(values: string[]): string[] {
  return [...new Set(values)].sort((a, b) => a.localeCompare(b));
}

function buildFilterControls(tags: string[], authors: string[]): string {
  const tagOptions = tags
    .map((tag) => `<option value="${escapeHTML(tag)}">${escapeHTML(tag)}</option>`)
    .join('');
  const authorOptions = authors
    .map((author) => `<option value="${escapeHTML(author)}">${escapeHTML(author)}</option>`)
    .join('');

  return `
    <section class="filters" aria-label="Mod filters">
      <label>
        <span>Filter by tag</span>
        <select data-filter="tag">
          <option value="">All tags</option>
          ${tagOptions}
        </select>
      </label>
      <label>
        <span>Filter by author</span>
        <select data-filter="author">
          <option value="">All authors</option>
          ${authorOptions}
        </select>
      </label>
      <button type="button" class="btn btn--ghost" data-filter="reset">Clear filters</button>
    </section>
  `;
}

export async function renderGame(gameId: string): Promise<void> {
  showLoading('Loading mods...');
  try {
    const { game, mods } = await getGameData(gameId);
    const modNameMap = new Map(mods.map((entry) => [entry.id, entry.name]));

    const renderModCard = (mod: ModSummary) => {
      const dependencies = mod.requires.length
        ? `<p class="meta">Requires: ${mod.requires
            .map((id) => `<span class="tag">${escapeHTML(modNameMap.get(id) ?? id)}</span>`)
            .join(' ')}</p>`
        : '';
      const authors = mod.authors.length ? `<p class="meta">By ${mod.authors.map(escapeHTML).join(', ')}</p>` : '';
      const tags = mod.tags.length
        ? `<div class="tag-list">${mod.tags.map((tag) => `<span class="tag">${escapeHTML(tag)}</span>`).join(' ')}</div>`
        : '';
      const description = formatInlineCode(mod.shortDesc);

      return `
        <a
          class="card card--link"
          href="${linkTo(`/game/${gameId}/mod/${mod.id}`)}"
          data-mod-card
          data-tags="${mod.tags.map(escapeHTML).join('|')}"
          data-authors="${mod.authors.map(escapeHTML).join('|')}"
        >
          <div class="card__header">
            <h3>${escapeHTML(mod.name)}</h3>
            <span class="pill">v${escapeHTML(mod.version)}</span>
          </div>
          <p>${description}</p>
          ${authors}
          ${tags}
          ${dependencies}
        </a>
      `;
    };

    const allTags = uniqueSorted(mods.flatMap((mod) => mod.tags));
    const allAuthors = uniqueSorted(mods.flatMap((mod) => mod.authors));

    const page = document.createElement('div');
    page.className = 'page';
    page.innerHTML = `
      <nav class="breadcrumbs" aria-label="Breadcrumb">
        <a href="${linkTo('/')}">All games</a>
        <span aria-hidden="true">/</span>
        <span>${escapeHTML(game.name)}</span>
      </nav>
      <section class="hero">
        <h1>${escapeHTML(game.name)}</h1>
        <p class="lead">Select a mod below or review the installation walkthrough.</p>
      </section>
      ${allTags.length || allAuthors.length ? buildFilterControls(allTags, allAuthors) : ''}
      <section class="grid grid--mods" aria-label="Mods">
        <a class="card card--link card--guide" href="${linkTo(`/game/${gameId}/install`)}">
          <h3>Mod Installation Guide</h3>
          <p>Setup instructions to install mods for ${escapeHTML(game.name)}.</p>
        </a>
        ${mods.map((mod) => renderModCard(mod)).join('')}
      </section>
      <p class="meta meta--empty" data-empty hidden>No mods match your current filters.</p>
    `;

    setPageContent(page);
    document.title = `${game.name} Mods`;

    const tagFilter = page.querySelector<HTMLSelectElement>('select[data-filter="tag"]');
    const authorFilter = page.querySelector<HTMLSelectElement>('select[data-filter="author"]');
    const resetButton = page.querySelector<HTMLButtonElement>('button[data-filter="reset"]');
    const cards = Array.from(page.querySelectorAll<HTMLElement>('[data-mod-card]'));
    const emptyIndicator = page.querySelector<HTMLElement>('[data-empty]');

    const applyFilters = () => {
      const tag = tagFilter?.value ?? '';
      const author = authorFilter?.value ?? '';
      let visibleCount = 0;

      for (const card of cards) {
        const cardTags = (card.dataset.tags ?? '').split('|').filter(Boolean);
        const cardAuthors = (card.dataset.authors ?? '').split('|').filter(Boolean);
        const matchesTag = !tag || cardTags.includes(tag);
        const matchesAuthor = !author || cardAuthors.includes(author);
        const isVisible = matchesTag && matchesAuthor;
        card.classList.toggle('is-hidden', !isVisible);
        if (isVisible) visibleCount += 1;
      }

      if (emptyIndicator) {
        emptyIndicator.toggleAttribute('hidden', visibleCount > 0);
      }
    };

    tagFilter?.addEventListener('change', applyFilters);
    authorFilter?.addEventListener('change', applyFilters);
    resetButton?.addEventListener('click', () => {
      if (tagFilter) tagFilter.value = '';
      if (authorFilter) authorFilter.value = '';
      applyFilters();
    });

    applyFilters();
  } catch (error) {
    console.error(error);
    showError('Unable to load game mods.', error instanceof Error ? error.message : undefined);
  }
}
