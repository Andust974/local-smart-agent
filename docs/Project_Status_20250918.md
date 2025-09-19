# Project Status — 18.09.2025

## 1. Local Smart Agent (LSA)
**Этап:** MVP готов, идёт переход к Marketplace Edition.  

**Сделано:**  
- Ollama, Squid (read-only), RAG, agentd, systemd юниты.  
- Skills: web_get/render, file_read, report_pack, dashboard_gen и др.  
- Dashboard с отчётами и ZIP-бандлами.  
- Task-API (FastAPI + uvicorn) поднят, health OK.  
- Inbox-watcher ловит JSON-задачи.  

**Проверено:** сквозной сценарий (UI → API → watcher → ZIP) проходит.  

**Не хватает:** Tray-агента, доработки UI/UX, basic-auth, бизнес-модулей (pdf→text, OCR, ssh whitelist), мониторинга, упаковки DevKit, auto-update.  

**Следующий шаг:** продакшн-уровень безопасности и удобства (basic-auth, UI-кнопки, logrotate, Tray).  

---

## 2. OCR (CC_OCR_Starter, часть DevKit)
**Этап:** доведено до production.  

**Сделано:**  
- OCR через Tesseract (eng+rus+pol).  
- API с маршрутами `/enqueue/ocr`, `/reports/ocr/*`.  
- Парсинг чеков: сумма, дата, магазин → parsed.json.  
- Автоочистка (оставляем 200 папок), backup старых отчётов.  
- Логирование в `logs/ocr_summary.log`.  
- systemd юниты: ocr-pipeline.service/timer, ocr-logrotate.service/timer.  

**Проверено:** pipeline (ocr_pipeline.sh) → отчёты создаются, normalize/parse/cleanup проходят, FAIL=0.  

**Не хватает:** финализировать README, включить таймеры по умолчанию, протестировать на реальной нагрузке.  

---

## 3. Marketplace Edition
**Этап:** Skeleton Freeze пройден, MVP интегрирован.  

**Сделано:**  
- Созданы папки (ui, scripts, tests, monitoring).  
- Заглушки для новых skills (pdf→text, OCR, ssh whitelist).  
- INSTALL.sh и QuickStart.md.  
- Dashboard дополнен кнопкой «Собрать бандл».  
- Подготовка к GitHub Release.  

**Не хватает:**  
- Доработки UI (web+tray).  
- Security (sandbox, basic-auth).  
- Новые skills.  
- Monitoring exporters.  
- Упаковка и публикация на Marketplace.  

---

## 4. Roadmap и стратегия
- **Месяц 1 (сентябрь):** MVP (PDF→TXT, API+watcher, dashboard).  
- **Месяц 2:** OCR + мониторинг.  
- **Месяц 3–4:** Self-train (LoRA), Tray-агент, sandbox.  
- **Месяц 5–6:** Enterprise-версия (VPN/basic-auth, SLA).  

---

## Итог
- **Local Smart Agent** — рабочее MVP, в стадии перехода к продаваемому DevKit.  
- **OCR** — доведён до продакшн.  
- **Marketplace Edition** — собран каркас, но ещё далеко до релиза (UI/UX, безопасность, упаковка).  
