# CHAT COMPRESSED — 2025-09-10

## OCR и API

- Настроен `task-api.service` (uvicorn + FastAPI).  
- Маршруты: `/health`, `/enqueue/ocr`, `/reports/ocr/latest`, `/reports/ocr/list`.  
- UI доступен по `/ui/index.html`.  

## OCR прогресс

- Проблема: tesseract не видел языки (`eng rus pol` → ошибка).  
- Исправлено: нормализована передача языков (`eng+rus+pol`).  
- Установлены и проверены языки в `/usr/share/tesseract-ocr/5/tessdata/` → `eng`, `rus`, `pol`, `osd`.  
- OCR работает: распознал тестовый PDF → `"OCR Test 123 ABC\nИ а. ИЕ jar"`.  
- Генерация отчётов: `reports/ocr/<id>/meta.json` и `text.txt` + `text_api_dump.txt`.

## systemd сервисы

- `task-api.service`: активен, слушает порт 8766, стартует uvicorn.  
- `inbox-watcher.service`: placeholder, следит за задачами в `tasks/inbox/`.  
- Проверка через `systemctl --user status` и `journalctl`.

## Ошибки и их исправления

1. `No module named uvicorn` → решено установкой в venv.  
2. `eng rus pol.traineddata` не найден → решено заменой на `eng+rus+pol` и настройкой `TESSDATA_PREFIX`.  
3. `openapi.json` → отсутствовал, решено корректным импортом `FastAPI` и `app`.  
4. Ошибки в `task_api.py`: не было `app`, исправлено добавлением `app = FastAPI()`.

## Текущее состояние

- OCR задачи выполняются, отчёты формируются.  
- API отвечает, UI открывается.  
- Проблемные отчёты с "error" зафиксированы и оставлены для истории.  
- Функционал OCR считается рабочим, идёт стабилизация для "production-level".

## Следующие шаги

- Расширить парсинг text.txt для чеков.  
- Добавить нормализацию символов.  
- Улучшить watcher: автоочистка и логирование.  
