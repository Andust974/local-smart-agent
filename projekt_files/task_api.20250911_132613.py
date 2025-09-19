#!/usr/bin/env python3
import os
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/health")
def health(token: str | None = None):
    token_env = os.getenv("TASK_API_TOKEN", "changeme")
    if token_env and token != token_env:
        return JSONResponse({"error": "unauthorized"}, status_code=401)
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    host = "127.0.0.1"
    port = int(os.getenv("TASK_API_PORT", "8766"))
    uvicorn.run("bin.task_api:app", host=host, port=port, reload=False, access_log=True)
