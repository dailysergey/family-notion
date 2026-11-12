# notion для SiYuan 3.8.10

Это конфигурация сервера notion.sguskov.com. Файлы index.html ссылаются на сборки из образа b3log/siyuan:v3.8.10. При смене версии сверьте имена JS/CSS и контрольную сумму Lute. Для другого домена замените имя хоста в Compose, конфигурации Nginx, OAuth и вспомогательных скриптах.

## Развёртывание

1. Поместите содержимое этой папки в /opt/notion. На действующем сервере используйте отдельный каталог для сравнения. Создайте закрытые локальные файлы с правами 0600. В .env задайте SIYUAN_ACCESS_AUTH_CODE. В mcp-db.env задайте POSTGRES_DB=keycloak, POSTGRES_USER=keycloak и POSTGRES_PASSWORD. В mcp-id.env задайте KC_DB_USERNAME, KC_DB_PASSWORD с теми же реквизитами, KC_BOOTSTRAP_ADMIN_USERNAME и KC_BOOTSTRAP_ADMIN_PASSWORD. В mcp.env задайте SIYUAN_TOKEN из настроек своего SiYuan после его первого запуска.
2. Подготовьте рабочие каталоги workspace и agent-account, доступные UID/GID 1000. Скопируйте mcp-realm.example.json в mcp-realm.json, замените подстановки новым секретом OAuth-клиента и точным callback URI вашего клиента Codex. Создайте пользователей realm в Keycloak. Импорт realm применяется при инициализации новой базы.
3. Подготовьте MCP-сервер из зафиксированной версии и примените локальную правку обнаружения OAuth.

~~~sh
git clone https://github.com/remixu1994/siyuan-mcp.git
git -C siyuan-mcp checkout b6852578382fea9d5ff24953ff24870fdb13c53c
git -C siyuan-mcp apply ../siyuan-mcp.patch
~~~

4. Compose использует внешнюю сеть nginx-proxy-manager_default. Подключите к ней прокси. Внутри Nginx Proxy Manager разместите site.conf в активной конфигурации, brand/public в /data/nginx/custom/notion/public, сертификат и ключ в путях ssl_certificate и ssl_certificate_key. В /data/nginx/custom/notion/langs поместите ru.json и en.json из app/appearance/langs этого тега вместе с их gzip-копиями. Проверьте дополнительные зависимости конфигурации NPM (ACME include и Docker DNS resolver). Проверьте nginx -t перед reload.
5. Выполните docker compose config -q и docker compose up -d --build. Для первого запуска ядра можно сначала выполнить docker compose up -d siyuan. После появления токена API завершите настройку mcp.env.
6. Для входа в ChatGPT выполните /opt/notion/connect-chatgpt --tunnel по SSH с интерактивным терминалом. Для синхронизации памяти установите Python 3 с requests, настройте доступ Git к /root/project-knowledge и проверьте привязку origin. Скопируйте notion-project-memory.service и notion-project-memory.timer в /etc/systemd/system. Выполните systemctl daemon-reload, systemctl start notion-project-memory.service и systemctl enable --now notion-project-memory.timer. Импорт запускается в 03:00 UTC.
