import { linkTo } from './navigation';

const root = document.querySelector<HTMLDivElement>('#app');

if (!root) {
  throw new Error('Root app container not found');
}

export function setPageContent(content: Node): void {
  root.replaceChildren(content);
}

export function showLoading(message = 'Loading...'): void {
  const container = document.createElement('div');
  container.className = 'page page--loading';
  container.innerHTML = `
    <div class="spinner" aria-hidden="true"></div>
    <p>${message}</p>
  `;
  setPageContent(container);
}

export function showError(title: string, details?: string): void {
  const container = document.createElement('div');
  container.className = 'page page--error';
  container.innerHTML = `
    <h1>${title}</h1>
    ${details ? `<p>${details}</p>` : ''}
    <a class="btn" href="${linkTo('/')}">Return home</a>
  `;
  setPageContent(container);
}