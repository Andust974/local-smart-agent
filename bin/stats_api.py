#!/usr/bin/env python3
import json, os, sys, time, subprocess, re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs
from pathlib import Path
ROOT = os.path.expanduser("~/ai-agent/projects/local_smart_agent")
SERVICES = ["local-agent.service","task-api.service","inbox-watcher.service","reports-index.service"]

def is_active(unit:str)->str:
    try:
        out = subprocess.check_output(["systemctl","--user","is-active",unit], stderr=subprocess.STDOUT, text=True).strip()
        return "active" if out=="active" else out
    except subprocess.CalledProcessError as e:
        return e.output.strip() or "unknown"

def count_dir(p:Path)->int:
    if not p.exists(): return 0
    return sum(1 for _ in p.iterdir() if _.is_file())

def human(n:int)->str:
    for u in ["B","KB","MB","GB","TB"]:
        if n < 1024: return f"{n:.0f} {u}"
        n /= 1024
    return f"{n:.0f} PB"

def list_bundles(rep:Path, k:int=5):
    items=[]
    for f in rep.glob("bundle_*.zip"):
        try:
            st=f.stat()
            items.append({"name":f.name,"path":str(f), "size":st.st_size, "size_h":human(st.st_size), "mtime":st.st_mtime})
        except: pass
    items.sort(key=lambda x:x["mtime"], reverse=True)
    out=[]
    for it in items[:k]:
        it2=it.copy()
        it2["mtime_iso"]=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(it["mtime"]))
        out.append(it2)
    return out

def reports_stats(rep:Path):
    total=0; size=0
    for f in rep.glob("report_*.html"):
        try:
            st=f.stat(); total+=1; size+=st.st_size
        except: pass
    # общий размер всей папки reports
    allsize=0
    for f in rep.rglob("*"):
        try:
            if f.is_file(): allsize+=f.stat().st_size
        except: pass
    return {"reports_count": total, "reports_size_bytes": size, "reports_size_h": human(size),
            "dir_size_bytes": allsize, "dir_size_h": human(allsize)}

def log_tail():
    # Берём user-journal local-agent, выцепляем ERROR/fail и последние 50 строк
    try:
        out = subprocess.check_output(
            ["journalctl","--user","-u","local-agent.service","-n","120","--no-pager"],
            text=True, stderr=subprocess.STDOUT
        )
    except subprocess.CalledProcessError as e:
        out = e.output
    lines = out.splitlines()
    # Подсветку сделаем на фронте, здесь просто отдаём строки и флажок has_error
    has_err = any(re.search(r"\b(ERROR|fail(ed)?)\b", L, re.IGNORECASE) for L in lines)
    return {"lines": lines[-120:], "has_error": bool(has_err)}

class H(BaseHTTPRequestHandler):
    def _send(self, code:int, data:dict, headers=None):
        body=json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type","application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin","*")
        if headers:
            for k,v in headers.items(): self.send_header(k,v)
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin","*")
        self.send_header("Access-Control-Allow-Methods","GET,POST,OPTIONS")
        self.send_header("Access-Control-Allow-Headers","Content-Type")
        self.end_headers()

    def do_GET(self):
        p = urlparse(self.path)
        if p.path == "/health":
            return self._send(200, {"status":"ok","service":"stats-api"})
        if p.path == "/stats":
            rep = Path(ROOT)/"reports"
            inbox = Path(ROOT)/"tasks/inbox"
            done  = Path(ROOT)/"tasks/done"
            failed = Path(ROOT)/"tasks/failed"
            fail = Path(ROOT)/"tasks/fail"
            tasks = {
                "inbox": count_dir(inbox),
                "done": count_dir(done),
                "failed": count_dir(failed) or count_dir(fail),
            }
            services = { s.replace(".service",""): is_active(s) for s in SERVICES }
            data = {
                "services": services,
                "tasks": tasks,
                "bundles": list_bundles(rep, k=5),
                "reports": reports_stats(rep),
                "log": log_tail(),
                "ts": int(time.time())
            }
            return self._send(200, data)
        self._send(404, {"error":"not found","path":p.path})

def main():
    port = int(os.getenv("STATS_API_PORT","8767"))
    srv = ThreadingHTTPServer(("127.0.0.1", port), H)
    print(f"[stats-api] listening on 127.0.0.1:{port}", flush=True)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass

if __name__=="__main__":
    main()
