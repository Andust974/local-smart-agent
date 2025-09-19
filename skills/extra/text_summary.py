#!/usr/bin/env python3
import sys, os
def main():
    if len(sys.argv) < 3:
        print("usage: text_summary.py IN.txt OUT.txt", file=sys.stderr); return 2
    inp, outp = sys.argv[1], sys.argv[2]
    if not os.path.exists(inp):
        print(f"[text_summary] no file {inp}", file=sys.stderr); return 1
    with open(inp, encoding="utf-8", errors="ignore") as f: lines=f.readlines()
    summary = "".join(lines[:5] + (["...\n"] if len(lines)>10 else []) + lines[-5:])
    os.makedirs(os.path.dirname(outp), exist_ok=True)
    with open(outp,"w",encoding="utf-8") as f: f.write(summary)
    print(f"[text_summary] OK: {outp}")
if __name__=="__main__": raise SystemExit(main())
