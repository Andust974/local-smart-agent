#!/usr/bin/env python3
import re, json, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
CORP=ROOT/"selftrain"/"rag"/"corpus"
IDX =ROOT/"memory"/"vectors"/"index.jsonl"
MAN =ROOT/"selftrain"/"metrics"/"rag_corpus_manifest.jsonl"
LOG =ROOT/"logs"/"selftrain"/"ingest_min2.log"
def strip_html(t):
    t=re.sub(r"(?is)<script.*?>.*?</script>"," ",t); t=re.sub(r"(?is)<style.*?>.*?</style>"," ",t); t=re.sub(r"(?is)<[^>]+>"," ",t); return t
def read_text(p):
    try:
        raw=p.read_text("utf-8",errors="ignore"); 
        return strip_html(raw) if p.suffix.lower() in {".html",".htm"} else raw
    except Exception: return ""
def norm(s): return re.sub(r"\s+"," ",s).strip()
def chunk(text,size=400,over=100):
    toks=text.split(); i=0
    while i<len(toks):
        yield " ".join(toks[i:i+size]); i+=(size-over if size>over else size)
def fake_emb(t,dims=256):
    h=hashlib.sha256(t.encode("utf-8","ignore")).digest()
    raw=(h*((dims//len(h))+1))[:dims]
    return [(b-128)/128.0 for b in raw]
LOG.parent.mkdir(parents=True, exist_ok=True)
IDX.parent.mkdir(parents=True, exist_ok=True)
MAN.parent.mkdir(parents=True, exist_ok=True)
open(IDX,"w",encoding="utf-8").close(); open(MAN,"w",encoding="utf-8").close()
files=[p for p in CORP.rglob("*") if p.is_file()]
total=0
with open(IDX,"a",encoding="utf-8") as oi, open(MAN,"a",encoding="utf-8") as om:
    for fp in files:
        txt=norm(read_text(fp))
        if not txt: continue
        chs=list(chunk(txt,400,100))[:8]
        for j,ch in enumerate(chs):
            oi.write(json.dumps({"id":f"{fp.relative_to(ROOT)}#{j}","text":ch,"embedding":fake_emb(ch)},ensure_ascii=False)+"\n")
        om.write(json.dumps({"file":str(fp.relative_to(ROOT)),"chunks":len(chs)},ensure_ascii=False)+"\n")
        total+=len(chs)
print("OK ingest_min2:", total, "chunks")
