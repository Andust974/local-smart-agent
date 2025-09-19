# Local Smart Agent → Marketplace Edition  
Полный, тщательный конспект чата (сжатие без потери смысла)  
Дата фиксации: 2025-09-09 14:45 CEST

---

## 0) Суть
Мы доводим **Local Smart Agent** до состояния продаваемого продукта (**Marketplace Edition**) по принципам **AI Domio**: простая установка (одна команда), локальная автономность, честная ценность/цена, аккуратная упаковка (UI, доки, DevKit). В чате последовательно: зафиксировали принципы и ТЗ, провели инвентаризацию проекта, устранили пробелы в структуре, ввели минимально рабочие сервисы (API, watcher, сбор бандлов отчётов), прописали юниты и подготовили базовую инфраструктуру для упаковки и мониторинга.

---

## 1) Базовые принципы и правила (то, на что опираемся)
- **AI Domio Way** (RU/EN): минимальное трение, автономность, честная цена↔ценность, модульность, продаваемость.  
  Файлы: `AI_DOMIO_WAY.md`, `AI_DOMIO_WAY_EN.md`.
- **Глобальное правило: Files via Bash Only** — любой файл создаётся через один bash-блок, зеркало в `projekt_files/_mirror`/`docs/_mirror`.  
  Файл: `GLOBAL_RULE_MAKE_FILES_VIA_BASH.md` (v1.1).
- **work_protocol.md / Follow_these_rules.md / text_preserve_method.md** — единый стиль работы, «длинные тексты = bash/python wrap», мега-правило ошибок (показывать файл/строку/причину/фикс).
- **Чек-лист реализации Marketplace Agent** — дорожная карта шагов (`CHECKLIST_Marketplace_Agent.md`).
- **ТЗ Marketplace Edition** — функциональные блоки, MVP→Prod, критерии приёмки, добавки для удорожания (`TS_Marketplace_Agent.md`).

---

## 2) ТЗ (коротко)
- **MVP:** установка одной командой; ядро агента + skills (web_read, report_pack|text_summary|word_count|merge_txt
- **Production:** Tray + Web UI; бизнес-модули (pdf→text, OCR, ssh_whitelist); безопасность (basic-auth, sandbox, VPN); мониторинг (Prometheus/Grafana); self-train/LoRA; автообновления DevKit.
- **Критерии приёмки:** всё из MVP работает; Dashboard доступен локально; read-only сеть; установка без ручных патчей; доки; готовность к продаже (маркетплейсы).

---

## 3) Инвентаризация проекта (до правок и после)
### До правок (по снимкам дерева)
- Были: `docs/` (часть доков), `skills/` (базовые), `tasks/` (без `inbox`/`done`/`failed`), отчёты и RAG-части, но **не хватало** UI-папки, скриптов в `bin/`, ядра в `core/`, `sandbox/dashboard.html`, ключевых **systemd**-юнитов (особенно `task-api.service`), мониторинга, logrotate, инсталлятора.

### После правок (что появилось)
- Папки: `ui/`, `skills/extra/`, `scripts/`, `tests/`, `sandbox/`, `monitoring/` (+ `grafana/`).
- Заглушки skills: `skills/extra/pdf2text.sh`, `ocr.sh`, `ssh_whitelist.sh`.
- Ядро/скрипты (заглушки): `core/agentd.sh`, `core/task_runner.sh`, `bin/report_pack|text_summary|word_count|merge_txt
- API (минимально рабочий): `bin/task_api.py` — реализует `GET /health` и `GET /report_pack|text_summary|word_count|merge_txt
- Очереди задач: `tasks/inbox/`, `tasks/done/`, `tasks/failed/`.
- **systemd user units** (заглушки/рабочие):  
  `~/.config/systemd/user/task-api.service`, `local-agent.service`, `inbox-watcher.service`, `reports-index.service`.
- `sandbox/dashboard.html` — минимальный дашборд; добавлена кнопка «Собрать бандл (N)» (JS вызывает `/report_pack|text_summary|word_count|merge_txt
- Инсталлятор и квик-старт: `INSTALL.sh`, `QuickStart.md` (не пустые, базовая логика).
- Мониторинг: `monitoring/prometheus.yml` (заглушка), `monitoring/grafana/datasource.yml` (заглушка).
- Logrotate: `/etc/logrotate.d/local_smart_agent` (ротация `logs/*.log`).

---

## 4) Что сделали по шагам (связка с чек-листом)
1. **Создали недостающие папки**: `ui/`, `skills/extra/`, `scripts/`, `tests/`.  
2. **Заглушки skills**: `pdf2text`, `ocr`, `ssh_whitelist`.  
3. **Инсталлятор и Quick Start**: добавлены и наполнены базовым содержимым.  
4. **Dashboard**: восстановлен `sandbox/dashboard.html`, добавлена кнопка «Собрать бандл (N)» (prompt → fetch `/report_pack|text_summary|word_count|merge_txt
5. **API**: создан минимально рабочий `bin/task_api.py` + unit `task-api.service` (порт `8766`, токен `changeme`).  
6. **Очереди задач**: созданы `tasks/inbox|done|failed`.  
7. **Watcher и бандл-складчик**: `bin/inbox_watcher.sh` (читает JSON-задачи, вызывает `bin/report_pack|text_summary|word_count|merge_txt
8. **Юниты**: `inbox-watcher.service`, `reports-index.service`, `local-agent.service` (заглушки), `daemon-reload` + `enable --now`.  
9. **Мониторинг и ротация**: заготовки Prometheus/Grafana и logrotate.  
10. **Проверка**: `/health` вернул `{"status":"ok"}`; `/report_pack|text_summary|word_count|merge_txt

---

## 5) Подтверждённые артефакты и команды
- `curl -s http://127.0.0.1:8766/health` → `{"status":"ok"}`.  
- `curl -s "http://127.0.0.1:8766/report_pack|text_summary|word_count|merge_txt"` → `{"queued":"tasks/inbox/task_...json"}`.  
- `ls -1 tasks/inbox | tail` → видно имя задачи; после работы watcher → появляется в `tasks/done/`.  
- ZIP-бандлы: `reports/bundle_*.zip` (содержат N последних `reports/*.html`; при отсутствии — генерятся placeholder-отчёты).

---

## 6) Ошибки, их причины и исправления (RCA)
- **Не было `tasks/inbox/`** → API некуда писать задачи → создали `tasks/inbox|done|failed`.  
- **Отсутствовал `task-api.service`** → `curl` молчал → создали unit в `~/.config/systemd/user/` и запустили.  
- **Heredoc обрывался** при создании файлов (`<<'SH'` не закрывался) → терминал «зависал» → перешли на безопасный способ (`printf '%s\n' ... > file`) и строго следим, чтобы heredoc закрывался.  
- **Токен**: использовали `changeme`; предупреждение — заменить на реальный секрет при упаковке.  
- **Dashboard без кнопки** → добавили `triggerBundle()` и вызов fetch к API.  
- **Отсутствовали `bin/core`-заглушки и `sandbox/`** → создали, чтобы проект стартовал без дыр.  
- **Мониторинг/лог-ротация** отсутствовали → добавлены заготовки и `logrotate` для стабильности.

---

## 7) Готово vs Не хватает
### Готово (MVP-уровень)
- Минимальная структура проекта (папки, заглушки, базовые скрипты).  
- Локальный рабочий API (`/health`, `/report_pack|text_summary|word_count|merge_txt
- Очередь задач и watcher (сквозной сценарий: «кнопка на UI → JSON в inbox → ZIP-бандл»).  
- Инсталлятор и квик-старт (базовые).  
- Заглушки мониторинга и ротации логов.

### Не хватает (для Production/продажи)
- **UI/UX:** доработать Dashboard (статусы сервисов, прогресс задач), добавить **Tray** (Linux/Win).  
- **Безопасность:** basic-auth на API, sandbox для skills, VPN/ngrok-профили.  
- **Бизнес-модули:** полноценный `pdf→text` (pdftotext/poppler или pymupdf), `OCR` (tesseract/google_mlkit), `ssh_whitelist`.  
- **Мониторинг:** поднять реальные Prometheus/Grafana (экспортеры), health-панель.  
- **Упаковка:** нормальный `INSTALL.sh` (проверки/зависимости), `README/QuickStart` с кейсами, лицензия, GitHub Releases (DevKit).  
- **Self-train/LoRA:** опционально для удорожания (включить профили обучения на локальных данных).  

---

## 8) Следующие шаги (из чек-листа → конкретика)
1. **API-безопасность:** внедрить basic-auth (минимум) и токен из `.env`/systemd-Environment.  
2. **UI-улучшения:** статус-панель (agent/api/watcher), список последних бандлов, кнопка «Открыть отчёт».  
3. **Tray-агент:** для Linux (python + pystray) с действиями: «Собрать бандл», «Открыть Dashboard», «Перезапустить сервисы».  
4. **pdf→text/OCR:** реализовать простые обёртки (tesseract/pdftotext), расширить чек-лист тестов.  
5. **Мониторинг:** реальный `node_exporter`/`process_exporter`, графики в Grafana, алерты.  
6. **Упаковка DevKit:** финализировать `INSTALL.sh`, `QuickStart.md`, `README.md`, добавить `LICENSE`, `CHANGELOG`, подготовить релиз.

---

## 9) Готовность к продаже — позиционирование
- **Что продаём:** локальный офлайн-агент с RAG-навыками, веб-рендером, отчётностью и кнопками управления, **без облачных подписок**.  
- **Ценность:** автономность, безопасность (read-only сеть), кастомизация через skills, простая установка.  
- **Повышение цены:** бизнес-модули (pdf→text, OCR, ssh-доступ), мониторинг/алерты, Tray-UX, self-train/LoRA.  
- **Форматы продажи:** DevKit (Gumroad/GitHub Marketplace), B2B-вариант (on-prem), кастом-модули как апсейл.

---

## 10) Ссылки на ключевые артефакты в проекте
- `docs/TS_Marketplace_Agent.md` — ТЗ.  
- `docs/CHECKLIST_Marketplace_Agent.md` — чек-лист.  
- `INSTALL.sh`, `QuickStart.md` — установка и запуск.  
- `sandbox/dashboard.html` — UI.  
- `bin/task_api.py`, `~/.config/systemd/user/task-api.service` — API.  
- `bin/inbox_watcher.sh`, `bin/report_pack|text_summary|word_count|merge_txt
- `tasks/inbox|done|failed` — очереди.  
- `monitoring/*` — мониторинг (заглушки).  
- `/etc/logrotate.d/local_smart_agent` — ротация логов.

---

## 11) Таймлайн ключевых событий (по чату)
- Зафиксированы принципы бренда и глобальные правила (Files via Bash Only; длинные тексты — через bash wrap).  
- Инвентаризация → выявлены отсутствующие юниты/папки/скрипты.  
- Созданы недостающие папки и заглушки.  
- Восстановлен Dashboard и добавлена кнопка «Собрать бандл (N)».  
- Реализован минимальный API (`/health`, `/report_pack|text_summary|word_count|merge_txt
- Настроен watcher + сбор ZIP-бандлов.  
- Добавлены заготовки мониторинга и ротации.  
- Сняты типовые ошибки (heredoc; отсутствие inbox/юнитов; токен).

---

## 12) Итог
**MVP готов и запускается сквозным сценарием.** Для выхода на маркетплейс остаётся дожать безопасность, UX, бизнес-модули и упаковку. Базовая архитектура и пайплайн задач функционируют; продукт из состояния «для себя» переведён в «к продаче» по дорожной карте.

---

_(Автогенерация: AI Domio • Marketplace Edition chat conspect)_  
