#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OCR Parse (minimal) — извлекает total, date, store из normalized.txt (или text.txt)
Пишет parsed.json и обновляет meta.json (добавляет store/total/currency/date/confidence)
Логирование ведёт вызывающий shell-скрипт.
"""

import re, json, sys, unicodedata
from pathlib import Path
from datetime import datetime

KW_TOTAL = [
    "razem do zapłaty","razem do zaplaty","do zapłaty","do zaplaty","razem","suma","total","grand total","amount due",
    "итог","всего","к оплате"
]
KNOWN_STORES = [
    "biedronka","lidl","żabka","zabka","carrefour","auchan","kaufland","netto","dino",
    "intermarché","intermarche","castorama","leroy merlin","pepco","jysk","action","hebe","rossmann"
]

def norm_text(t: str) -> str:
    t = unicodedata.normalize("NFKC", t or "")
    t = t.replace("\r","\n")
    t = re.sub(r"[^\x09\x0A\x0D\x20-\x7E\u00A0-\u024F\u0400-\u04FF]", "", t)
    t = re.sub(r"[ \t]+", " ", t)
    t = re.sub(r"\n{3,}", "\n\n", t)
    return t.strip()

def parse_money_token(tok: str):
    s = tok.replace(" ", "")
    if "," in s and "." in s:
        s = s.replace(".", "").replace(",", ".")
    else:
        s = s.replace(",", ".")
    try:
        v = round(float(s), 2)
        return v
    except Exception:
        return None

def find_total(lines):
    money_re = re.compile(r"(?<!\d)(\d{1,5}(?:[.,]\d{3})*[.,]\d{2})(?:\s*(PLN|ZŁ|zł|zl))?", re.I)
    # сначала ищем строки с ключами
    for i, ln in enumerate(lines):
        low = ln.lower()
        if any(k in low for k in KW_TOTAL) or ("pln" in low or "zł" in low or " zl" in low):
            hits = list(money_re.finditer(ln))
            if hits:
                v = parse_money_token(hits[-1].group(1))
                if v is not None:
                    return v, "PLN", f"kw_line:{i+1}"
    # фоллбек: максимальная сумма в документе
    candidates = []
    for i, ln in enumerate(lines):
        for m in money_re.finditer(ln):
            v = parse_money_token(m.group(1))
            if v is not None:
                candidates.append((v, i, m.group(0)))
    if candidates:
        v,i,tok = sorted(candidates, key=lambda x:x[0], reverse=True)[0]
        return v, "PLN", f"fallback_max:{tok}@{i+1}"
    return None, None, "none"

def find_date(text):
    # поддерживаем DD.MM.YYYY | DD/MM/YYYY | DD-MM-YYYY | YYYY-MM-DD | YYYY.MM.DD
    pats = [
        r"\b(\d{4})[-./](\d{2})[-./](\d{2})\b",
        r"\b(\d{2})[-./](\d{2})[-./](\d{4})\b",
    ]
    for p in pats:
        m = re.search(p, text)
        if m:
            g = m.groups()
            try:
                if len(g[0])==4:
                    dt = datetime(int(g[0]), int(g[1]), int(g[2]))
                else:
                    dt = datetime(int(g[2]), int(g[1]), int(g[0]))
                return dt.date().isoformat(), f"pat:{p}"
            except Exception:
                continue
    return None, "none"

def find_store(lines):
    text_l = "\n".join(lines).lower()
    for s in KNOWN_STORES:
        if s in text_l:
            return s.title(), "known"
    # хедер: первые строки без служебных слов
    SKIP = ("paragon","fiskalny","faktura","sprzedawca","kasjer","nip","nr","kasa","terminal","vat","tax","pos")
    for raw in lines[:6]:
        l = raw.strip()
        if not l: continue
        low = l.lower()
        if any(k in low for k in SKIP): 
            continue
        if re.search(r"[A-Za-zĄąćĘęŁłŃńÓóŚśŹźŻżА-Яа-я]", l):
            return l, "head"
    return None, "none"

def score(total_ok, date_ok, store_ok):
    base = 0.6
    if total_ok: base += 0.2
    if date_ok:  base += 0.1
    if store_ok: base += 0.1
    return round(max(0.0, min(1.0, base)), 2)

def parse_report_dir(rep: Path) -> dict:
    txt = rep/"normalized.txt"
    if not txt.exists():
        txt = rep/"text.txt"
    if not txt.exists():
        raise FileNotFoundError(f"no text in {rep}")
    raw = txt.read_text(encoding="utf-8", errors="ignore")
    norm = norm_text(raw)
    lines = [ln.strip() for ln in norm.splitlines()]

    total, curr, r_total = find_total(lines)
    date, r_date = find_date(norm)
    store, r_store = find_store(lines)

    reasons = {"amount_reason": r_total, "date_reason": r_date, "store_reason": r_store}
    conf = score(total is not None, date is not None, store is not None)

    parsed = {
        "store": store,
        "total": total,
        "currency": curr or "PLN",
        "date": date,
        "confidence": conf,
        "reasons": reasons
    }

    # write parsed.json
    (rep/"parsed.json").write_text(json.dumps(parsed, ensure_ascii=False, indent=2), encoding="utf-8")

    # merge into meta.json (non-destructive)
    meta_p = rep/"meta.json"
    meta = {}
    if meta_p.exists():
        try:
            meta = json.loads(meta_p.read_text(encoding="utf-8", errors="ignore") or "{}")
        except Exception:
            meta = {}
    meta.update({k: parsed[k] for k in ("store","total","currency","date","confidence")})
    meta_p.write_text(json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8")

    return parsed

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"ok": False, "error": "usage: ocr_parse_min.py /abs/path/to/reports/ocr/<id>"}))
        sys.exit(2)
    rep = Path(sys.argv[1]).resolve()
    if not rep.is_dir():
        print(json.dumps({"ok": False, "error": f"not a dir: {rep}"}))
        sys.exit(2)
    try:
        parsed = parse_report_dir(rep)
        print(json.dumps({"ok": True, "dir": str(rep), "parsed": parsed}, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({"ok": False, "dir": str(rep), "error": str(e)}, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()
