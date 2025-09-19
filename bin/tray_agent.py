#!/usr/bin/env python3
import os, signal, subprocess, time

PRJ = os.path.expanduser("~/ai-agent/projects/local_smart_agent")
DASH = os.path.join(PRJ, "sandbox", "dashboard.html")

def run(cmd):
    try: subprocess.run(cmd, check=True)
    except Exception as e: print("[tray-agent] ERROR:", e)

def start_ocr(*_):
    print("[tray-agent] action: START OCR")
    run(["systemctl","--user","start","ocr-pipeline.service"])

def stop_ocr(*_):
    print("[tray-agent] action: STOP OCR")
    run(["systemctl","--user","stop","ocr-pipeline.service"])

def open_dash(*_):
    print("[tray-agent] action: OPEN DASH")
    if os.path.exists(DASH):
        run(["xdg-open", DASH])
    else:
        print("[tray-agent] dashboard not found:", DASH)

def graceful_exit(*_):
    print("[tray-agent] exit requested"); raise SystemExit(0)

signal.signal(signal.SIGUSR1, start_ocr)
signal.signal(signal.SIGUSR2, stop_ocr)
signal.signal(signal.SIGHUP,  open_dash)
signal.signal(signal.SIGTERM, graceful_exit)
signal.signal(signal.SIGINT,  graceful_exit)

print("[tray-agent] running. Signals: USR1=start, USR2=stop, HUP=open dash, TERM/INT=exit")
while True:
    time.sleep(30)
