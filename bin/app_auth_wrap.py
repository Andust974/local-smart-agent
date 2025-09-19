import os, base64, ipaddress
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.openapi.docs import get_swagger_ui_html
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.applications import Starlette

# Базовое приложение импортируем как есть (его код не трогаем)
from bin.task_api import app as _app

_ALLOW_OPEN = ("/health", "/tasks/ping")
_ALLOW_NETS = [ "127.0.0.1/32", "192.168.1.0/24" ]  # скорректируй под свою сеть

class BasicAuthMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self.user = os.getenv("TASK_API_BASIC_USER", "lsa")
        self.pwd  = os.getenv("TASK_API_BASIC_PASS", "changeme")
        self.need = "Basic " + base64.b64encode(f"{self.user}:{self.pwd}".encode()).decode()

    def _client_allowed(self, request: Request) -> bool:
        try:
            ip = request.client.host
            return any(ipaddress.ip_address(ip) in ipaddress.ip_network(net) for net in _ALLOW_NETS)
        except Exception:
            return False

    async def dispatch(self, request: Request, call_next):
        p = str(request.url.path)
        if any(p.startswith(x) for x in _ALLOW_OPEN) or self._client_allowed(request):
            return await call_next(request)
        auth = request.headers.get("Authorization", "")
        if auth != self.need:
            resp = JSONResponse({"detail":"Unauthorized"}, status_code=401)
            resp.headers["WWW-Authenticate"] = "Basic"
            return resp
        return await call_next(request)

# Компонующее приложение: явные роуты + монтирование основного API
root = Starlette()

@root.route("/openapi.json")
async def openapi_json(request):
    return JSONResponse(_app.openapi())

@root.route("/docs")
async def docs(request):
    return get_swagger_ui_html(openapi_url="/openapi.json", title="Task API Docs")

@root.route("/redoc")
async def redoc(request):
    # Если у _app включен redoc, отдаст сам; иначе 404 — это ок
    try:
        return await _app.__call__(request.scope, request.receive, request.send)  # pass-through
    except Exception:
        return JSONResponse({"detail": "not available"}, status_code=404)

# Монтируем основной API на корень
@root.middleware("http")
async def _mount_app(request: Request, call_next):
    # Перенаправляем всё остальное в _app
    path = request.url.path
    if path in ("/openapi.json", "/docs", "/redoc"):
        return await call_next(request)
    return await _app(request.scope, request.receive, request.send)

# Навешиваем BasicAuth (вкл. по флагу)
app = root
if os.getenv("TASK_API_BASIC_ENABLE", "1") == "1":
    app.add_middleware(BasicAuthMiddleware)
