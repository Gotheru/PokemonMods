import { assetUrl, getMod, getModManifest } from '../api';
import { linkTo } from '../navigation';
import type { ModManifest } from '../types';
import { setPageContent, showLoading, showError } from '../render';
import { highlightCode } from '../highlight';
import { escapeHTML, formatInlineCode, formatRichText } from '../utils/html';

interface CodeSampleViewModel {
  label: string;
  language?: string;
  content: string;
}

function resolveModAsset(gameId: string, modId: string, assetPath: string): string {
  const base = assetUrl(`mods/${gameId}/${modId}/`);
  return new URL(assetPath, base).toString();
}

function buildDependenciesList(
  gameId: string,
  deps: string[],
  modMap: Map<string, { id: string; name: string }>,
): string {
  if (!deps.length) return '<p class="meta">No additional requirements.</p>';
  return `
    <p class="meta">Requires: ${deps
      .map((dep) => {
        const target = modMap.get(dep);
        return target
          ? `<a class="tag" href="${linkTo(`/game/${gameId}/mod/${target.id}`)}">${escapeHTML(target.name)}</a>`
          : `<span class="tag tag--missing">${escapeHTML(dep)}</span>`;
      })
      .join(' ')}</p>
  `;
}

async function loadCodeSamples(
  gameId: string,
  modId: string,
  manifest: ModManifest | null,
): Promise<CodeSampleViewModel[]> {
  if (!manifest?.codeSamples?.length) return [];
  const samples = await Promise.all(
    manifest.codeSamples.map(async (sample) => {
      try {
        const url = resolveModAsset(gameId, modId, sample.path);
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`Failed to load ${sample.path}`);
        }
        const content = await response.text();
        return {
          label: sample.label,
          language: sample.language,
          content,
        };
      } catch (error) {
        console.warn('Failed to load code sample', sample.path, error);
        return {
          label: sample.label,
          language: sample.language,
          content: 'Unable to load sample file.',
        };
      }
    }),
  );
  return samples;
}

function renderImages(gameId: string, modId: string, manifest: ModManifest | null): string {
  if (!manifest?.images?.length) return '';
  const items = manifest.images
    .map((image) => {
      const url = resolveModAsset(gameId, modId, image.path);
      const alt = escapeHTML(image.alt ?? '');
      return `<figure class="preview"><img src="${url}" alt="${alt}"><figcaption>${alt}</figcaption></figure>`;
    })
    .join('');
  return `<section class="previews" aria-label="Screenshots">${items}</section>`;
}

function renderMetadataList(authors: string[], tags: string[], version: string): string {
  const items: string[] = [];
  items.push(`<li><span>Version</span><strong>${escapeHTML(version)}</strong></li>`);
  if (authors.length) {
    items.push(`<li><span>Authors</span><strong>${authors.map(escapeHTML).join(', ')}</strong></li>`);
  }
  if (tags.length) {
    items.push(`<li><span>Tags</span><strong>${tags.map(escapeHTML).join(', ')}</strong></li>`);
  }
  return `<ul class="meta-list">${items.join('')}</ul>`;
}

export async function renderMod(gameId: string, modId: string): Promise<void> {
  showLoading('Loading mod details...');
  try {
    const { data, mod } = await getMod(gameId, modId);
    const manifest = await getModManifest(gameId, modId);
    const codeSamples = await loadCodeSamples(gameId, modId, manifest);

    const downloadFile = manifest?.download?.filename ?? '';
    const downloadUrl = downloadFile ? resolveModAsset(gameId, modId, downloadFile) : null;
    const downloadExt = downloadFile ? (downloadFile.split('.').pop() ?? '').toLowerCase() : '';
    const downloadLabel =
      downloadExt === 'zip'
        ? 'Download ZIP'
        : `Download ${downloadExt ? downloadExt.toUpperCase() : 'File'}`;

    const modMap = new Map(data.mods.map((m) => [m.id, m]));
    const deps = buildDependenciesList(gameId, mod.requires, modMap);

    const longDescription = mod.desc?.trim();
    const descriptionHtml = longDescription
      ? formatRichText(longDescription)
      : `<p class="lead">${formatInlineCode(mod.shortDesc)}</p>`;
    const leadHtml = longDescription ? '' : '';

    const page = document.createElement('div');
    page.className = 'page';
    page.innerHTML = `
      <nav class="breadcrumbs" aria-label="Breadcrumb">
        <a href="${linkTo('/')}">All games</a>
        <span aria-hidden="true">/</span>
        <a href="${linkTo(`/game/${gameId}`)}">${escapeHTML(data.game.name)}</a>
        <span aria-hidden="true">/</span>
        <span>${escapeHTML(mod.name)}</span>
      </nav>
      <article class="mod-detail">
        <header>
          <h1>${escapeHTML(mod.name)}</h1>
          ${renderMetadataList(mod.authors, mod.tags, mod.version)}
          ${deps}
        </header>
        ${leadHtml}
        <div class="mod-detail__body">${descriptionHtml}</div>
        ${
          downloadUrl
            ? `<a class="btn btn--primary" href="${downloadUrl}" download>${downloadLabel}</a>`
            : '<p class="meta">Download coming soon.</p>'
        }
      </article>
      ${renderImages(gameId, modId, manifest)}
      ${
        codeSamples.length
          ? `<section class="code" aria-label="Code samples">
              <h2>Code snippets</h2>
              ${codeSamples
                .map(
                  (sample) => `
                    <article>
                      <header>
                        <h3>${escapeHTML(sample.label)}</h3>
                        ${sample.language ? `<span class="tag">${escapeHTML(sample.language)}</span>` : ''}
                      </header>
                      <pre><code class="${sample.language ? `language-${escapeHTML(sample.language)}` : ''}">${escapeHTML(sample.content)}</code></pre>
                    </article>
                  `,
                )
                .join('')}
            </section>`
          : ''
      }
    `;

    setPageContent(page);
    highlightCode(page);
    document.title = `${mod.name} - ${data.game.name}`;
  } catch (error) {
    console.error(error);
    showError('Unable to load mod.', error instanceof Error ? error.message : undefined);
  }
}
