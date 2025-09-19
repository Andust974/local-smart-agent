# CHAT COMPRESSED — 2025-09-09 … 2025-09-11 (FULL)

## Базовый прогресс до Marketplace (2025-09-09)
- Установлен Ollama, ограничен лимит моделей.
- Настроен прокси Squid (read-only GET/HEAD).
- Развёрнут RAG (ингест/запросы, индекс JSONL).
- systemd: local-agent, rag-indexer.timer.
- Skills: web_get, report_pack, dashboard_gen и др.
- Dashboard и PNG-скриншот.
- Ядро agentd, watcher.
- Ошибки (inbox, unit) → исправлены.
- Результат: API + dashboard работают, сквозной сценарий (UI→API→watcher→ZIP) проходит.

## Marketplace Edition (2025-09-09, 14:45)
- Принципы: AI Domio Way, Global Rule: Files via Bash Only.
- Протоколы: work_protocol.md, Follow_these_rules.md, text_preserve_method.md.
- MVP: установка одной командой, ядро+skills, локальный API, dashboard.
- Prod: Tray+Web UI, бизнес-модули, безопасность, мониторинг, self-train, автообновления.
- Сделано: недостающие папки, заглушки skills, API task_api.py, watcher/report_pack, systemd units, dashboard кнопка «Собрать бандл», INSTALL.sh, QuickStart.md, заглушки мониторинга.
- Проверка: curl /health → {"status":"ok"}, /report_pack → queued JSON, watcher → done.
- Ошибки и фиксы: отсутствующие папки и units созданы, heredoc заменены на printf, dashboard доработан.
- Готово: минимальная структура, API, watcher, install, заглушки.
- Не хватает: UI/UX доработка, Tray, безопасность, бизнес-модули, мониторинг, упаковка, self-train.

## OCR и API (2025-09-10)
- Настроен task-api.service (uvicorn + FastAPI).
- Маршруты: /health, /enqueue/ocr, /reports/ocr/latest, /reports/ocr/list.
- UI по /ui/index.html.
- OCR: исправлен выбор языков (eng+rus+pol).
- Работает: распознан тестовый PDF → "OCR Test 123 ABC…".
- Отчёты: meta.json, text.txt, text_api_dump.txt.
- Сервисы: task-api.service и inbox-watcher.service активны.
- Ошибки и фиксы: uvicorn, openapi.json, app=FastAPI, языки Tesseract.
- Состояние: OCR рабочий, API отвечает, UI открывается.

## OCR Production (2025-09-11)
- Нормализация символов (очистка артефактов, UTF-8).
- Парсинг чеков: сумма, дата, магазин в parsed.json.
- Автоочистка OCR-папок: последние 200 директорий, остальное backup или удаление.
- Логирование: тег ocr-prod, стадии normalize/parse/cleanup в logs/ocr_summary.log.
- systemd Units: ocr-pipeline.service/timer, ocr-logrotate.service/timer.
- DoD: ocr_pipeline.sh → новые отчёты, логи в ocr_summary.log, старые удаляются/архивируются.
- Ошибки и фиксы: OCR_LOG, пути /home/andrei-work, project_check.log.
- Сервисные скрипты: ocr_norm.sh, ocr_parse.sh, ocr_cleanup.sh, ocr_pipeline.sh, ocr_logrotate.sh.
- Журнал: normalize OK=6, parse OK=3, cleanup OK=1, FAIL=0.
- Следующие шаги: финализировать README (OCR_Prod_README.md), включить таймеры systemd, проверить auto-backup.

## Итог
- MVP готов, Marketplace Edition частично реализован.
- OCR-пайплайн доведён до продакшн-уровня.
- Следующие шаги: безопасность (basic-auth), улучшения UI, Tray, новые skills, мониторинг, упаковка DevKit.
