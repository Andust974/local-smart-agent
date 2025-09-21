import os, base64, ipaddress
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi.responses import JSONResponse
from fastapi.openapi.docs import get_swagger_ui_html

# импортируем базовое приложение (как есть)
from bin.task_api import app as _app

_ALLOW_OPEN = ("/health", "/tasks/ping")
_ALLOW_NETS = ["127.0.0.1/32", "192.168.1.0/24"]  # поправишь при надобности

class BasicAuthMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self.user = os.getenv("TASK_API_BASIC_USER", "lsa")
        self.pwd  = os.getenv("TASK_API_BASIC_PASS", "changeme")
        self.need = "Basic " + base64.b64encode(f"{self.user}:{self.pwd}".encode()).decode()

    def _client_allowed(self, request: Request) -> bool:
        try:
            ip = request.client.host
            return any(ipaddress.ip_address(ip) in ipaddress.ip_network(n) for n in _ALLOW_NETS)
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

# явные маршруты для OpenAPI/Swagger
from fastapi import FastAPI
root = FastAPI()
@root.get("/openapi.json")
def _openapi(): return _app.openapi()
@root.get("/docs")
def _docs(): return get_swagger_ui_html(openapi_url="/openapi.json", title="Task API Docs")

# монтируем основной app и вешаем мидлварь
from fastapi import Request as _R
@root.middleware("http")
async def _mount(request: _R, call_next):
    if request.url.path in ("/openapi.json", "/docs"):  # уже обработали
        return await call_next(request)
    return await _app(request.scope, request.receive, request.send)

app = root
if os.getenv("TASK_API_BASIC_ENABLE", "1") == "1":
    app.add_middleware(BasicAuthMiddleware)
