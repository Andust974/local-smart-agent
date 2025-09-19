# UI/UX Plan — Tray & Dashboard

## Dashboard (web)
- [ ] Filters: date range, source, status
- [ ] Stats: total docs, success rate, avg OCR time
- [ ] Actions: Open Reports Index, Download Latest ZIP
- [ ] Live logs tail (last 100 lines)
- [ ] No-refresh updates (basic setInterval)
- [ ] Error banners (red), success (green)
- [ ] Zero-state (no reports) friendly message

## Tray Agent (Linux)
- [ ] Minimal tray menu: Start/Stop OCR, Show Dashboard, Tail Logs, Quit
- [ ] User-level systemd integration
- [ ] Desktop notification on errors
- [ ] Config path: ~/.config/local_smart_agent/config.json
- [ ] Logs: logs/tray_agent.log
- [ ] Dependencies check (python3, gi/Qt or fallback)

## Milestones
- [ ] M1: Dashboard v1 (filters+stats)
- [ ] M2: Tray skeleton + systemd unit
- [ ] M3: Notifications + health checks
- [ ] M4: Polish (icons, theming)
