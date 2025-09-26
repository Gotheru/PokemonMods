export type RouteHandler = (params: string[], ctx: { path: string }) => Promise<void> | void;

interface Route {
  pattern: RegExp;
  handler: RouteHandler;
}

export class Router {
  private routes: Route[];
  private notFound: RouteHandler;
  private isNavigating = false;
  private basePath: string;
  private baseRoot: string;

  constructor(routes: Route[], notFound: RouteHandler, basePath: string) {
    this.routes = routes;
    this.notFound = notFound;
    const normalized = basePath.startsWith('/') ? basePath : `/${basePath}`;
    this.basePath = normalized.endsWith('/') ? normalized : `${normalized}/`;
    this.baseRoot = this.basePath.replace(/\/$/, '');
  }

  private toRelative(path: string): string {
    if (this.basePath === '/') return path;
    if (path === this.basePath || path === this.baseRoot) return '/';
    if (path.startsWith(this.basePath)) {
      const rest = path.slice(this.basePath.length);
      return rest ? `/${rest}` : '/';
    }
    if (path.startsWith(this.baseRoot)) {
      const rest = path.slice(this.baseRoot.length);
      return rest ? rest : '/';
    }
    return path;
  }

  private toAbsolute(path: string): string {
    if (this.basePath === '/') return path;
    const trimmedPath = path.startsWith('/') ? path : `/${path}`;
    return `${this.baseRoot}${trimmedPath}`;
  }

  public start(): void {
    window.addEventListener('popstate', () => this.navigate(window.location.pathname, { replace: true }));
    document.addEventListener('click', (event) => {
      const target = (event.target as HTMLElement | null)?.closest('a');
      if (!target) return;

      const href = target.getAttribute('href');
      if (!href || href.startsWith('http') || href.startsWith('mailto:') || href.startsWith('#')) return;

      const url = new URL(href, window.location.origin);
      if (url.origin !== window.location.origin) return;

      event.preventDefault();
      this.navigate(url.pathname);
    });

    void this.navigate(window.location.pathname, { replace: true });
  }

  public async navigate(path: string, options: { replace?: boolean } = {}): Promise<void> {
    if (this.isNavigating) return;
    this.isNavigating = true;
    try {
      const relative = this.toRelative(path);
      const route = this.routes.find((r) => r.pattern.test(relative));
      const ctx = { path: relative };
      if (!route) {
        await this.notFound([], ctx);
        return;
      }
      const match = relative.match(route.pattern);
      const params = match ? match.slice(1) : [];
      const targetPath = options.replace ? this.toAbsolute(relative) : this.toAbsolute(relative);
      if (options.replace) {
        window.history.replaceState({}, '', targetPath);
      } else {
        window.history.pushState({}, '', targetPath);
      }
      await route.handler(params, ctx);
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } finally {
      this.isNavigating = false;
    }
  }
}