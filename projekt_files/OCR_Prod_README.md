# OCR Production Pack

## Компоненты
- bin/ocr_normalize.py — нормализация → normalized.txt
- bin/ocr_parse_min.py — парсинг total/date/store → parsed.json (+ meta.json)
- bin/ocr_norm_run.sh, bin/ocr_parse_run.sh — обёртки с логированием (тег ocr-prod)
- bin/ocr_cleanup.sh — автоочистка reports/ocr/* (DRY-RUN по умолчанию)
- bin/ocr_pipeline.sh — pipeline: normalize → parse
- bin/ocr_log.sh — единый логгер (nounset-safe)
- bin/ocr_summary.sh — сводка OK/FAIL

## Ручной запуск
bin/ocr_pipeline.sh --limit 10
bin/ocr_summary.sh

## Автозапуск (user-systemd)
systemctl --user daemon-reload
systemctl --user enable --now ocr-pipeline.timer
journalctl --user -u ocr-pipeline.service -n 200 -f
