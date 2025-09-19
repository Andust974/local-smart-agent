# Pricing & Features — Local Smart Agent

## MVP (входит в продажу уже сейчас)
- Dashboard (статусы, задачи, бандлы, лог)
- API + inbox-watcher (полный цикл задач)
- Skills:
  - report_pack
  - dashboard_gen
  - journal_analyze
  - pdf_to_text
- RAG-память (ingest + query)
  - Автоматическая индексация новых документов (RAG v1)
- Сервисы systemd: local-agent, task-api, inbox-watcher, reports-index
- Поддержка read-only доступа к вебу (через Squid)

**Цена (MVP):**
- Подписка: $19–29/мес
- Разовая лицензия: $149

---

## Premium Upgrade (будет в следующих версиях)
- OCR (чтение сканов, чеков)
- JSON-метаданные при PDF→TXT
- Monitoring (Prometheus/Grafana)
- Self-train (LoRA / RAG v2)
- Tray-агент (Linux/Win)
- Sandbox для skills
- Автообновления DevKit

**Цена (Premium):**
- Подписка: $39–49/мес
- Add-ons:
  - OCR: +$10–15/мес
  - Self-train/LoRA: +$20/мес
- Enterprise (SLA, VPN, кастомизация): $1 000–2 000/год
