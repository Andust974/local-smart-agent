# Local Smart Agent — Sprint Plan (v1.0 Release)

## Цель спринта
Довести Local Smart Agent до версии **1.0 (Starter Release)**, чтобы он был готов к публичному показу и первым пользователям.

---

## Kanban Board

### 🟢 To Do
- [ ] Подготовить `install.sh` для автоматической установки зависимостей
- [ ] Подготовить `docker-compose.yml` для контейнерного запуска
- [ ] Проверить systemd unit (`task-api.service`) на чистый запуск
- [ ] Реализовать API: `/tasks`, `/analysis/{file}`, `/logs/{service}`, `/health`
- [ ] Сделать единообразные JSON-ответы
- [ ] Реализовать очередь задач (Task Manager)
- [ ] Добавить логирование задач в SQLite/JSON
- [ ] Сделать ограничение по параллельности задач
- [ ] Подключить Tesseract OCR (PDF/JPG)
- [ ] Реализовать File Parser (CSV ↔ JSON)
- [ ] Сделать Log Analyzer (systemd ошибки)
- [ ] Сделать веб-панель (FastAPI + Jinja2/Vue)
- [ ] Реализовать форму загрузки файлов (OCR результат)
- [ ] Реализовать таблицу последних задач
- [ ] Реализовать просмотр логов ошибок
- [ ] Добавить BasicAuth авторизацию
- [ ] Написать README.md с инструкцией по установке и API
- [ ] Подготовить OpenAPI docs (Swagger UI)
- [ ] Добавить примеры `curl` запросов
- [ ] Подготовить GitHub repo (open-core)
- [ ] Сделать Release v1.0 (Starter)
- [ ] Опубликовать Docker Hub image
- [ ] Снять короткое демо-видео
- [ ] Провести smoke-тест всех функций
- [ ] Исправить баги
- [ ] Составить roadmap для v1.1 (Pro Pack)

### 🟡 In Progress
- [ ] ...

### 🔵 Done
- [ ] ...
