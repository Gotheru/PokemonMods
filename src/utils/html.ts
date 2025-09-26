const ENTITY_MAP: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
};

export function escapeHTML(value: string): string {
  return value.replace(/[&<>"']/g, (char) => ENTITY_MAP[char] ?? char);
}

export function formatInlineCode(value: string): string {
  return escapeHTML(value).replace(/`([^`]+)`/g, '<code>$1</code>');
}

export function formatRichText(value: string): string {
  if (!value.trim()) return '<p></p>';
  const blocks = value.split(/\n{2,}/);
  return blocks
    .map((block) => {
      const inline = formatInlineCode(block.trim());
      return `<p>${inline.replace(/\n/g, '<br>')}</p>`;
    })
    .join('');
}