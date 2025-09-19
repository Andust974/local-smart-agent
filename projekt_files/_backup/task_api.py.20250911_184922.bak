from fastapi import FastAPI
from fastapi.responses import JSONResponse
import os

app = FastAPI()

@app.get("/health")
def health(token: str | None = None):
    tok = os.getenv("TASK_API_TOKEN", "changeme")
    if tok and token != tok:
        return JSONResponse({"error": "unauthorized"}, status_code=401)
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=int(os.getenv("TASK_API_PORT","8766")))
