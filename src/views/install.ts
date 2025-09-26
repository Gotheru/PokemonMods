import { getGameData, getInstallGuide } from '../api';
import { linkTo } from '../navigation';
import { setPageContent, showLoading, showError } from '../render';
import { formatInlineCode } from '../utils/html';

function markdownToHtml(markdown: string): string {
  const lines = markdown.split(/\r?\n/);
  const html: string[] = [];
  let paragraph: string[] = [];
  let listType: 'ul' | 'ol' | null = null;

  const flushParagraph = () => {
    if (paragraph.length) {
      html.push(`<p>${formatInlineCode(paragraph.join(' '))}</p>`);
      paragraph = [];
    }
  };

  const flushList = () => {
    if (listType) {
      html.push(`</${listType}>`);
      listType = null;
    }
  };

  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line) {
      flushParagraph();
      flushList();
      continue;
    }

    if (line.startsWith('```')) {
      // Ignoring fenced blocks for now
      continue;
    }

    const headingMatch = line.match(/^(#{1,3})\s+(.*)$/);
    if (headingMatch) {
      flushParagraph();
      flushList();
      const level = headingMatch[1].length;
      const content = formatInlineCode(headingMatch[2]);
      html.push(`<h${level}>${content}</h${level}>`);
      continue;
    }

    const orderedMatch = line.match(/^\d+\.\s+(.*)$/);
    if (orderedMatch) {
      flushParagraph();
      if (listType !== 'ol') {
        flushList();
        listType = 'ol';
        html.push('<ol>');
      }
      html.push(`<li>${formatInlineCode(orderedMatch[1])}</li>`);
      continue;
    }

    const unorderedMatch = line.match(/^[-*]\s+(.*)$/);
    if (unorderedMatch) {
      flushParagraph();
      if (listType !== 'ul') {
        flushList();
        listType = 'ul';
        html.push('<ul>');
      }
      html.push(`<li>${formatInlineCode(unorderedMatch[1])}</li>`);
      continue;
    }

    if (line.startsWith('>')) {
      flushParagraph();
      flushList();
      html.push(`<blockquote>${formatInlineCode(line.slice(1).trim())}</blockquote>`);
      continue;
    }

    paragraph.push(line);
  }

  flushParagraph();
  flushList();
  return html.join('\n');
}

export async function renderInstall(gameId: string): Promise<void> {
  showLoading('Loading guide...');
  try {
    const { game } = await getGameData(gameId);
    const guide = await getInstallGuide(gameId);
    const html = markdownToHtml(guide);

    const page = document.createElement('div');
    page.className = 'page install';
    page.innerHTML = `
      <nav class="breadcrumbs" aria-label="Breadcrumb">
        <a href="${linkTo('/')}">All games</a>
        <span aria-hidden="true">/</span>
        <a href="${linkTo(`/game/${gameId}`)}">${game.name}</a>
        <span aria-hidden="true">/</span>
        <span>Installation guide</span>
      </nav>
      <section class="hero">
        <h1>${game.name} mod installation</h1>
        <p class="lead">Follow the steps below to install mods safely.</p>
      </section>
      <article class="guide" aria-label="Installation steps">
        ${html}
      </article>
      <a class="btn" href="${linkTo(`/game/${gameId}`)}">Back to mods</a>
    `;

    setPageContent(page);
    document.title = `${game.name} - Installation`;
  } catch (error) {
    console.error(error);
    showError('Unable to load installation guide.', error instanceof Error ? error.message : undefined);
  }
}