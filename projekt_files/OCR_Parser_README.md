# OCR Parser (production step 1/4)
Компоненты:
- tools/ocr_parser/parse_receipt.py — извлекает total/date/store из OCR text.txt и обновляет meta.json.
- bin/ocr_parse_receipt.sh — массовый прогон по reports/ocr/* (по умолчанию 10 последних).

Запуск:
  bin/ocr_parse_receipt.sh              # 10 последних
  bin/ocr_parse_receipt.sh reports/ocr/<id>  # один отчёт

Вывод:
- В каждой папке отчёта: parsed.json + обновлённый meta.json (ключи total/date/store/confidence).
- Логи: logs/ocr_parser.log
