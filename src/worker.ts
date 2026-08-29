interface Env {
  ASSETS: Fetcher;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // 1. Intentar servir el recurso estático exacto
    let response = await env.ASSETS.fetch(request);
    if (response.status !== 404) {
      return response;
    }

    // 2. Fallback SPA para diapositivas: /tutorias/IC3101/SXX/... -> /tutorias/IC3101/SXX/index.html
    const match = url.pathname.match(/^(\/tutorias(?:\/IC3101)?\/S\d{2})/);
    if (match) {
      const weekRoot = match[1];
      const indexUrl = new URL(`${weekRoot}/index.html`, url.origin);
      const spaResponse = await env.ASSETS.fetch(new Request(indexUrl.toString(), {
        method: "GET",
        headers: request.headers,
      }));
      if (spaResponse.status === 200) {
        return spaResponse;
      }
    }

    // 3. Fallback para /tutorias o /tutorias/ -> /tutorias/IC3101/index.html
    if (url.pathname === "/tutorias" || url.pathname === "/tutorias/") {
      const portalUrl = new URL("/tutorias/IC3101/index.html", url.origin);
      return env.ASSETS.fetch(new Request(portalUrl.toString(), {
        method: "GET",
        headers: request.headers,
      }));
    }

    return response;
  }
};
