#!/usr/bin/env python3
import sys, os, json, time, shutil, subprocess, pathlib, re

def write_meta(outdir, **meta):
    os.makedirs(outdir, exist_ok=True)
    with open(os.path.join(outdir, "meta.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)

def run(cmd, timeout=None):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=timeout)

def is_pdf(p): return str(p).lower().endswith(".pdf")
def list_imgs(pages_dir): return sorted([str(p) for p in pathlib.Path(pages_dir).glob("*.png")])

def get_installed_langs():
    try:
        r = run(["tesseract", "--list-langs"], timeout=8)
        if r.returncode == 0:
            langs = [ln.strip() for ln in r.stdout.splitlines() if ln.strip() and not ln.startswith("List of")]  # tesseract header
            return set(langs)
    except Exception:
        pass
    return set()

def normalize_lang(lang):
    # принятый формат: eng+rus+pol
    if not lang: return "eng"
    lang = lang.replace("%20","+").replace(" ", "+").strip("+")
    # убираем дубль плюсов
    lang = re.sub(r"\++", "+", lang)
    return lang or "eng"

def clean_text(s):
    # простая нормализация для production-качества
    s = s.replace("\u00AD","")        # мягкие переносы
    s = s.replace("\u2014","—")       # длинное тире
    s = s.replace("\u2013","–")       # среднее тире
    s = re.sub(r"[ \t]+", " ", s)     # лишние пробелы
    s = re.sub(r"\n{3,}", "\n\n", s)  # лишние пустые строки
    return s.strip()

def main():
    if len(sys.argv) < 3:
        print("usage: ocr_scan.py IN.(pdf|png|jpg) OUTDIR [lang]", file=sys.stderr); return 2
    inp, outdir = sys.argv[1], sys.argv[2]
    req_lang = normalize_lang(sys.argv[3] if len(sys.argv)>3 else "eng+rus+pol")

    t0 = time.time()
    os.makedirs(outdir, exist_ok=True)
    pages_dir = os.path.join(outdir, "pages"); os.makedirs(pages_dir, exist_ok=True)

    # лицензия (мягко)
    lic_path = os.path.expanduser("~/.config/lsa/license.json")
    if os.path.exists(lic_path):
        try:
            lic = json.load(open(lic_path, encoding="utf-8"))
            if lic.get("plan") not in ("pro","trial"):
                write_meta(outdir, status="subscription_required", requested_lang=req_lang)
                return 0
        except Exception:
            pass

    if not os.path.exists(inp):
        write_meta(outdir, status="bad_input", errors=[f"no such file: {inp}"], requested_lang=req_lang)
        return 0

    have_tess = shutil.which("tesseract") is not None
    have_pdftoppm = shutil.which("pdftoppm") is not None
    have_pdftocairo = shutil.which("pdftocairo") is not None
    have_pdftotext = shutil.which("pdftotext") is not None

    if is_pdf(inp):
        errs, imgs = [], []
        if have_pdftoppm:
            r = run(["pdftoppm", "-r", "300", "-png", inp, os.path.join(pages_dir, "page")])
            if r.returncode == 0: imgs = list_imgs(pages_dir)
            else: errs.append(r.stderr.strip())
        if not imgs and have_pdftocairo:
            r2 = run(["pdftocairo", "-png", "-r", "300", inp, os.path.join(pages_dir, "page")])
            if r2.returncode == 0: imgs = list_imgs(pages_dir)
            else: errs.append(r2.stderr.strip())
        if not imgs and have_pdftotext:
            txt_out = os.path.join(outdir, "text.txt")
            r3 = run(["pdftotext", "-layout", inp, txt_out])
            if r3.returncode == 0 and os.path.exists(txt_out):
                dur = round(time.time()-t0,2)
                # лёгкая подчистка
                try:
                    t = open(txt_out, "r", encoding="utf-8", errors="ignore").read()
                    open(txt_out, "w", encoding="utf-8").write(clean_text(t))
                except Exception: pass
                write_meta(outdir, status="pdf_text_extracted", pages=0, requested_lang=req_lang, duration_sec=dur, warnings=["rasterize_failed"], errors=errs)
                print(f"[ocr_scan] OK(pdf_text_extracted): {outdir}")
                return 0
        if not imgs:
            write_meta(outdir, status="error", requested_lang=req_lang, errors=errs or ["pdf rasterize failed"])
            return 0
        images = imgs
    else:
        images = [inp]

    if not have_tess:
        write_meta(outdir, status="missing_tesseract", requested_lang=req_lang, errors=["tesseract not found"])
        return 0

    # языки: пересечение запрошенных и установленных
    installed = get_installed_langs()
    requested = [p for p in req_lang.split("+") if p]
    valid = [p for p in requested if p in installed]
    use_lang = "+".join(valid) if valid else ("eng" if "eng" in installed else "")

    if not use_lang:
        write_meta(outdir, status="missing_languages", requested_lang=req_lang, installed=sorted(list(installed)), errors=["no matching langs installed"])
        return 0

    # OCR с таймаутом и устойчивостью
    texts, t_errs = [], []
    for img in images:
        try:
            # psm 6 — предположительно блоки параграфов; можно вынести в конфиг
            r = run(["tesseract", img, "stdout", "-l", use_lang, "--psm", "6"], timeout=60)
            if r.returncode != 0:
                t_errs.append(r.stderr.strip() or f"tesseract failed on {os.path.basename(img)}"); break
            texts.append(r.stdout)
        except subprocess.TimeoutExpired:
            t_errs.append(f"timeout on {os.path.basename(img)} (60s)"); break

    if t_errs:
        write_meta(outdir, status="error", requested_lang=req_lang, used_lang=use_lang, errors=t_errs)
        return 0

    full = clean_text("\n\n".join([t.strip() for t in texts]))
    with open(os.path.join(outdir, "text.txt"), "w", encoding="utf-8") as f:
        f.write(full)

    write_meta(outdir, status="ok", pages=len(images) if is_pdf(inp) else 1, requested_lang=req_lang, used_lang=use_lang, duration_sec=round(time.time()-t0,2))
    print(f"[ocr_scan] OK: {outdir}")
    return 0

if __name__=="__main__":
    raise SystemExit(main())
