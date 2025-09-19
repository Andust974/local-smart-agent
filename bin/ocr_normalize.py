#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OCR Normalizer — production step 2
Читает text.txt, чистит от артефактов, пишет normalized.txt
"""

import sys, unicodedata, re
from pathlib import Path

def normalize_text(t: str) -> str:
    # Unicode NFC/NFKC нормализация
    t = unicodedata.normalize("NFKC", t or "")
    # убираем \r и мусорные невидимые
    t = t.replace("\r", "\n")
    t = re.sub(r"[^\x09\x0A\x0D\x20-\x7E\u00A0-\u024F\u0400-\u04FF]", "", t)
    # схлопываем пробелы и табы
    t = re.sub(r"[ \t]+", " ", t)
    # убираем тройные+ переносы
    t = re.sub(r"\n{3,}", "\n\n", t)
    # частные артефакты OCR
    t = t.replace("И а.", "И.А.")
    t = t.replace("ИЕ jar", "ПИВО")  # пример маппинга, можно расширять словарь
    return t.strip()

def main():
    if len(sys.argv) < 2:
        print("usage: ocr_normalize.py /path/to/reports/ocr/<id>/text.txt")
        sys.exit(1)
    infile = Path(sys.argv[1]).resolve()
    if not infile.exists():
        print(f"[ERROR] not found: {infile}")
        sys.exit(2)
    raw = infile.read_text(encoding="utf-8", errors="ignore")
    norm = normalize_text(raw)
    outfile = infile.parent / "normalized.txt"
    outfile.write_text(norm, encoding="utf-8")
    print(f"[OK] normalized: {outfile}")

if __name__ == "__main__":
    main()
