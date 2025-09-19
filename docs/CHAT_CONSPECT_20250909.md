# CHAT_CONSPECT_20250909

## Общее
Конспект чата о запуске и отладке Local Smart Agent. Цель — довести стек (task-api + inbox-watcher) до стабильной работы без вылетов.

## Диагностика и проблемы
- task-api часто стартовал как "placeholder" → переписали `task_api_start.sh` и unit systemd.  
- Несовпадения путей (`/home/andrei` vs `/home/andrei-work`) → вычищено, все пути жёстко приведены к `/home/andrei-work`.  
- Вылеты при постановке задач → watcher не понимал `"task": "report_pack"`. Добавили поддержку `kind=report_pack`.  
- 403 ошибки при `curl` → процесс не видел правильного токена. Исправлено: systemd unit грузит `.env`, а процесс берёт `TASK_API_TOKEN`.  

## Проверки
- `/health` → стабильно `{"status": "ok"}`.  
- `/report_pack` с токеном из `.env` → задачи успешно попадают в `tasks/inbox/` и уходят в `tasks/done/`.  
- watcher пишет в лог: `[watcher] report_pack … done`.  

## Токены
- Проверено: ENV и LIVE токены совпадают (`ENV=…  LIVE=…`).  
- Токен читается из `.config/lsa/.env` и подхватывается процессом.  

## Бандлы
- Автоматическая генерация zip в `reports/`.  
- Стабильное обновление symlink `latest_bundle.zip`.  

## Hotkeys
- В `~/.bashrc.d/lsa_hotkeys.sh` добавлены:  
  - `rp` — ставит задачу (берёт токен из `.env` автоматически).  
  - `rb` — показывает путь к последнему бандлу и обновляет symlink.  
- Проверка: `rp 1 && sleep 2 && rb` → работает.  

## Selftest
- Добавлен `bin/selftest.sh`: проверяет /health, /report_pack и генерацию нового бандла.  
- Запуск завершился `[OK] latest → …`.  

## Вывод
- Вылеты устранены.  
- task-api и inbox-watcher работают стабильно.  
- Полный стек протестирован: API → очередь → watcher → bundle.  
- Система готова к дальнейшему развитию (переход на Bearer-авторизацию, mini-UI для скачивания ZIP).

