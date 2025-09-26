const base = import.meta.env.BASE_URL.startsWith('/') ? import.meta.env.BASE_URL : '/' + import.meta.env.BASE_URL;
const normalized = base.endsWith('/') ? base : base + '/';

export function linkTo(path: string): string {
  let trimmed = path;
  while (trimmed.startsWith('/')) {
    trimmed = trimmed.slice(1);
  }
  if (!trimmed) {
    return normalized;
  }
  return normalized + trimmed;
}
