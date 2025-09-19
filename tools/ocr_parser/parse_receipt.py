#!/usr/bin/env python3
import json, sys, unicodedata, re
from pathlib import Path

def _norm_text(t: str) -> str:
    t = unicodedata.normalize("NFKC", t or "")
    t = t.replace("\r", "\n")
    t = re.sub(r"[^\x09\x0A\x0D\x20-\x7E\u00A0-\u024F\u0400-\u04FF]", "", t)
    t = re.sub(r"[ \t]+", " ", t)
    t = re.sub(r"\n{3,}", "\n\n", t)
    return t.strip()

def main():
    if len(sys.argv) < 2:
        print('{"ok":false,"error":"usage: parse_receipt.py /abs/path/to/reports/ocr/<id>"}')
        sys.exit(2)
    rep = Path(sys.argv[1]).resolve()
    text_file = rep / "text.txt"
    if not text_file.exists():
        print(json.dumps({"ok": False, "error": f"not found: {text_file}"}))
        sys.exit(1)
    raw = text_file.read_text(encoding="utf-8", errors="ignore")
    norm = _norm_text(raw)
    parsed = {"store": None, "total": None, "currency": "PLN", "date": None, "confidence": 0.0, "reasons": {"normalized": True}, "preview": norm[:200]}
    (rep / "parsed.json").write_text(json.dumps(parsed, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps({"ok": True, "dir": str(rep)}))

if __name__ == "__main__":
    main()
