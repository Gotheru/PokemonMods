import hljs from 'highlight.js/lib/core';
import ruby from 'highlight.js/lib/languages/ruby';

hljs.registerLanguage('ruby', ruby);

export function highlightCode(root: ParentNode | Document = document): void {
  root.querySelectorAll<HTMLElement>('pre code').forEach((block) => {
    hljs.highlightElement(block);
  });
}