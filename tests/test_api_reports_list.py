import json, urllib.request, sys
BASE = "http://127.0.0.1:8766"
def get(path):
    with urllib.request.urlopen(BASE + path, timeout=3) as r:
        return r.getcode(), json.load(r)
# health
code, body = get("/health")
assert code == 200 and body.get("status") == "ok", f"health bad: {code} {body}"
# reports/list
code, body = get("/reports/list?limit=5")
assert code == 200 and isinstance(body, list), f"list bad: {code} type={type(body)}"
if body:
    need = {"id","status","path"}
    assert need.issubset(body[0].keys()), f"keys missing: {need - set(body[0].keys())}"
print("TEST_OK")
