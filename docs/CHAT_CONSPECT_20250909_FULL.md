# Local Smart Agent → Marketplace Edition (Full Chat Conspect)

Дата объединения: 2025-09-09

---

## Часть 1. Базовый прогресс (до Marketplace)
(по материалам от 2025-09-03)

### Что сделано
- Установлен Ollama, ограничен лимит моделей.
- Настроен прокси Squid (read-only GET/HEAD).
- Развёрнут RAG (ингест/запросы, индекс JSONL).
- systemd: `local-agent.service`, `rag-indexer.timer`.
- Ядро `core/agentd` с фиксом путей, runner.
- Skills: web_get/render/pw_render, file_read, analyze_squid, report_pack, report_html_merge, agent_diag, docker_ps, git_local, journal_analyze, dashboard_gen.
- Генерация отчётов и бандлов.
- Dashboard (`sandbox/dashboard.html` + png).

### Состояние сервисов
- ollama, squid, local-agent, rag-indexer.timer → active.

### Артефакты
- Последние отчёты и бандлы, dashboard.html/png.
- Дерево каталогов (bin, core, docs, memory, models, reports, tasks, watcher…).
- Логи journal + access.log Squid.

### Что осталось
- Подключение UI/Tray.
- Расширение skills (ssh whitelist, pdf→text).
- Prometheus/Grafana.
- LoRA/self-train.

---

## Часть 2. Улучшения (индексация, API, watcher)
(по материалам от 2025-09-03, 07:01)

### Сделано
- Исправлен `bin/gen_reports_index.sh` + сервис/таймер.
- Dashboard: кнопки Reports Index/Latest ZIP.
- Реализован `bin/report_pack.sh` + skill + API `/report_pack`.
- Поднят `task-api.service` (порт 8766, токен).
- Inbox-watcher.service обрабатывает JSON-задачи.
- Синхронизация токена/порта с dashboard.
- Проверка: API активен, health OK, задачи ставятся.

### Текущее состояние
- Отчёты и бандлы создаются.
- task-api.service и inbox-watcher.service → active.
- Dashboard обновлён.

### Следующие шаги
1. Кнопка «Собрать бандл (N)».
2. Добавить статистику в отчёты.
3. Привести к единому логированию + logrotate.
4. (Опц.) Вывести API наружу (basic-auth/VPN).

---

## Часть 3. Marketplace Edition
(по материалам от 2025-09-09, 14:45)

### Принципы
- AI Domio Way: минимальное трение, автономность, честная цена.
- Global Rule: Files via Bash Only.
- Протоколы: work_protocol.md, Follow_these_rules.md, text_preserve_method.md.
- Чек-лист и ТЗ Marketplace Edition.

### ТЗ (коротко)
- MVP: установка одной командой, ядро+skills, локальный API, dashboard.
- Prod: Tray+Web UI, бизнес-модули, безопасность, мониторинг, self-train, автообновления.
- Критерии: всё из MVP работает, dashboard доступен, доки, продаваемость.

### Инвентаризация и правки
- Созданы недостающие папки (ui, skills/extra, scripts, tests, sandbox, monitoring).
- Добавлены заглушки skills.
- Реализованы API (task_api.py), очереди задач, watcher/report_pack.
- systemd units (task-api, local-agent, inbox-watcher, reports-index).
- Dashboard: кнопка «Собрать бандл».
- INSTALL.sh, QuickStart.md.
- Мониторинг и logrotate (заглушки).

### Проверка
- curl /health → {"status":"ok"}.
- curl /report_pack → JSON-задача + bundle.zip.
- Watcher перемещает задачи в done.

### Ошибки и фиксы
- Не было папки inbox → создали.
- Отсутствовал task-api.service → добавлен.
- Ошибки heredoc → перешли на printf.
- Dashboard без кнопки → добавили JS.
- Нет заглушек core/sandbox → созданы.
- Нет мониторинга/logrotate → добавлены.

### Готово vs Не хватает
- Готово: минимальная структура, API, watcher, install, заглушки.
- Не хватает: UI/UX доработка, Tray, безопасность, бизнес-модули, мониторинг, упаковка, self-train.

### Следующие шаги
- Basic-auth в API.
- Улучшения UI.
- Tray-агент.
- pdf→text/OCR.
- Мониторинг exporters.
- Упаковка DevKit.

### Позиционирование
- Продаётся как локальный офлайн-агент без облака.
- Ценность: автономность, безопасность, простота установки.
- Цена ↑ через бизнес-модули, мониторинг, UX, self-train.

---

## Итог
- MVP работает сквозным сценарием (UI→API→watcher→ZIP).
- Подготовлен к продаже как DevKit, но требуется доработка для продакшн-уровня.
- Проект прошёл путь: от базового агента → улучшенный RAG/API/watcher → Marketplace Edition.

