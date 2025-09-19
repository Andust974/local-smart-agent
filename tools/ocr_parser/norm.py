#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import unicodedata, re

def norm_text(t: str) -> str:
    """Нормализация OCR-текста:
    - NFKC (склейка совместимых символов, лат/кирилл/польские)
    - удаление управляющих и мусора
    - схлопывание пробелов и пустых строк
    """
    if not isinstance(t, str):
        t = str(t) if t is not None else ""
    t = unicodedata.normalize("NFKC", t)
    t = t.replace("\r", "\n")
    t = re.sub(r"[^\x09\x0A\x0D\x20-\x7E\u00A0-\u024F\u0400-\u04FF]", "", t)
    t = re.sub(r"[ \t]+", " ", t)
    t = re.sub(r"\n{3,}", "\n\n", t)
    return t.strip()
