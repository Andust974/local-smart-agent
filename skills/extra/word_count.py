#!/usr/bin/env python3
import sys, os, json
def main():
    if len(sys.argv) < 3:
        print("usage: word_count.py IN.txt OUT.json", file=sys.stderr); return 2
    inp, outp = sys.argv[1], sys.argv[2]
    if not os.path.exists(inp):
        print(f"[word_count] no file {inp}", file=sys.stderr); return 1
    text=open(inp,encoding="utf-8",errors="ignore").read()
    words=text.split()
    stats={"chars":len(text),"words":len(words),"unique_words":len(set(words))}
    os.makedirs(os.path.dirname(outp),exist_ok=True)
    with open(outp,"w",encoding="utf-8") as f: f.write(json.dumps(stats,ensure_ascii=False,indent=2))
    print(f"[word_count] OK: {outp}")
if __name__=="__main__": raise SystemExit(main())
