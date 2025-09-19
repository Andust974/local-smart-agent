#!/usr/bin/env python3
import sys, os
def main():
    if len(sys.argv) < 3:
        print("usage: merge_txt.py OUT.txt IN1.txt [IN2.txt...]", file=sys.stderr); return 2
    outp, inps = sys.argv[1], sys.argv[2:]
    merged=[]
    for p in inps:
        if os.path.exists(p):
            merged.append(open(p,encoding="utf-8",errors="ignore").read())
    os.makedirs(os.path.dirname(outp),exist_ok=True)
    with open(outp,"w",encoding="utf-8") as f: f.write("\n\n".join(merged))
    print(f"[merge_txt] OK: {outp}")
if __name__=="__main__": raise SystemExit(main())
