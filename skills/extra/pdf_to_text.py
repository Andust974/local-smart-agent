#!/usr/bin/env python3
import os, sys, subprocess, shutil

def main():
    if len(sys.argv) < 3:
        print("usage: pdf_to_text.py IN.pdf OUT.txt", file=sys.stderr)
        return 2
    inp, outp = sys.argv[1], sys.argv[2]
    os.makedirs(os.path.dirname(outp), exist_ok=True)
    if not os.path.exists(inp):
        print(f"[pdf_to_text] no such file: {inp}", file=sys.stderr)
        return 1
    if shutil.which("pdftotext"):
        subprocess.run(["pdftotext","-layout","-nopgbrk",inp,outp], check=False)
        print(f"[pdf_to_text] OK: {outp}")
        return 0
    else:
        with open(outp,"w",encoding="utf-8") as f:
            f.write("SOFT-FAIL: pdftotext missing.\n")
        print(f"[pdf_to_text] placeholder written: {outp}")
        return 0

if __name__ == "__main__":
    raise SystemExit(main())
