
## [MVP harden] 2025-09-10
- Dashboard: добавлены OCR-кнопка (enqueue), панель «OCR: последний результат», список отчётов, копирование и скачивание TXT.
- API: эндпойнты `/health`, `/enqueue/ocr`, `/reports/ocr/list`, `/reports/ocr/latest`, `/reports/ocr/text?id=`.
- Сервис: переведён на uvicorn в venv (`.venv/bin/uvicorn core.task_api:app`), CORS + раздача UI по `/ui/`.
- Watcher: включён `core/watch_any.sh` под systemd; очередь inbox→runner→reports работает стабильно.
- OCR: прод-улучшения в `skills/extra/ocr_scan.py` — нормализация языков, auto-detect установленных, fallback, таймауты, cleanup текста, pdf→png (pdftoppm/pdftocairo), fallback на `pdftotext`.
- Диагностика: добавлен `core/ocr_doctor.sh`.
- Окружение: `TESSDATA_PREFIX` прописан в unit-override для `task-api.service` и `inbox-watcher.service`.

## [MVP harden] 2025-09-10
- Dashboard: добавлены OCR-кнопка (enqueue), панель «OCR: последний результат», список отчётов, копирование и скачивание TXT.
- API: эндпойнты `/health`, `/enqueue/ocr`, `/reports/ocr/list`, `/reports/ocr/latest`, `/reports/ocr/text?id=`.
- Сервис: переведён на uvicorn в venv (`.venv/bin/uvicorn core.task_api:app`), CORS + раздача UI по `/ui/`.
- Watcher: включён `core/watch_any.sh` под systemd; очередь inbox→runner→reports работает стабильно.
- OCR: прод-улучшения в `skills/extra/ocr_scan.py` — нормализация языков, auto-detect установленных, fallback, таймауты, cleanup текста, pdf→png (pdftoppm/pdftocairo), fallback на `pdftotext`.
- Диагностика: добавлен `core/ocr_doctor.sh`.
- Окружение: `TESSDATA_PREFIX` прописан в unit-override для `task-api.service` и `inbox-watcher.service`.

## [MVP harden] 2025-09-10
- Dashboard: добавлены OCR-кнопка (enqueue), панель «OCR: последний результат», список отчётов, копирование и скачивание TXT.
- API: эндпойнты `/health`, `/enqueue/ocr`, `/reports/ocr/list`, `/reports/ocr/latest`, `/reports/ocr/text?id=`.
- Сервис: переведён на uvicorn в venv (`.venv/bin/uvicorn core.task_api:app`), CORS + раздача UI по `/ui/`.
- Watcher: включён `core/watch_any.sh` под systemd; очередь inbox→runner→reports работает стабильно.
- OCR: прод-улучшения в `skills/extra/ocr_scan.py` — нормализация языков, auto-detect установленных, fallback, таймауты, cleanup текста, pdf→png (pdftoppm/pdftocairo), fallback на `pdftotext`.
- Диагностика: добавлен `core/ocr_doctor.sh`.
- Окружение: `TESSDATA_PREFIX` прописан в unit-override для `task-api.service` и `inbox-watcher.service`.
