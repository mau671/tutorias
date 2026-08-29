interface Env {
  ASSETS: Fetcher;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // 1. Try to serve exact static asset first
    let response = await env.ASSETS.fetch(request);
    if (response.status !== 404) {
      return response;
    }

    // 2. Subpath SPA fallback: /tutorias/IC3101/SXX/... -> /tutorias/IC3101/SXX/index.html
    const match = url.pathname.match(/^(\/tutorias(?:\/IC3101)?\/S\d{2})/);
    if (match) {
      const weekRoot = match[1];
      const indexUrl = new URL(`${weekRoot}/index.html`, url.origin);
      const fallbackResponse = await env.ASSETS.fetch(new Request(indexUrl.toString(), request));
      if (fallbackResponse.status === 200) {
        return fallbackResponse;
      }
    }

    // 3. Fallback for /tutorias or /tutorias/
    if (url.pathname === "/tutorias" || url.pathname === "/tutorias/") {
      const portalUrl = new URL("/tutorias/IC3101/index.html", url.origin);
      return env.ASSETS.fetch(new Request(portalUrl.toString(), request));
    }

    return response;
  }
};
