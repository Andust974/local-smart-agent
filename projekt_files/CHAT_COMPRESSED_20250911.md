# CHAT COMPRESSED — 2025-09-11

## OCR Production

- Настроена нормализация символов (очистка артефактов вроде `И а. ИЕ jar`, перевод в UTF-8).
- Парсинг чеков: извлечение суммы, даты и магазина в `parsed.json`.
- Автоочистка OCR-папок: оставляем последние 200 директорий, остальное переносим в backup или удаляем.
- Логирование: единый тег `ocr-prod`, все стадии (`normalize`, `parse`, `cleanup`) в `logs/ocr_summary.log`.

## systemd Units

- `ocr-pipeline.service` + `ocr-pipeline.timer` для периодического запуска.
- `ocr-logrotate.service` + `ocr-logrotate.timer` для ротации логов.
- Все юниты хранятся в `~/.config/systemd/user/`.

## DoD (Definition of Done)

- `bin/ocr_pipeline.sh --limit N` → создаются новые отчёты в `reports/ocr/`.
- `logs/ocr_summary.log` → видны успешные normalize/parse/cleanup.
- Старые OCR-репорты уходят в backup/ или удаляются.
- Логи автоматически ротируются в `logs/archive/`.

## Ошибки и фиксы

- Ошибка `OCR_LOG: не заданы границы переменной` → добавили экспорт переменной в `ocr_log.sh`.
- Старые пути `/home/andrei/` заменены на `/home/andrei-work/`.
- Проверка проекта (`project_check.log`) теперь учитывает адрес с `-work`.

## Сервисные скрипты

- `bin/ocr_norm.sh`, `bin/ocr_parse.sh`, `bin/ocr_cleanup.sh` → отдельные шаги.
- `bin/ocr_pipeline.sh` → объединение в конвейер.
- `bin/ocr_logrotate.sh` → архивирование логов старше 5 МБ.

## Журнал

- Сводка по OCR собирается в `ocr_summary.log`.
- Последние проверки: normalize OK=6, parse OK=3, cleanup OK=1, FAIL=0.

## Следующие шаги

- Финализировать README (`OCR_Prod_README.md`) с примерами запуска.
- Включить таймеры systemd по умолчанию.
- Проверить auto-backup OCR-репортов на реальной нагрузке.

