#!/bin/bash
set -euo pipefail
umask 077
cd /opt/notion
exec 9>/run/lock/siyuan-backup.lock
flock -n 9
store=/var/backups/siyuan
archive="$store/siyuan-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
temp=$(mktemp "$store/.partial.XXXXXXXX")
dumpdir=$(mktemp -d "$store/.identity.XXXXXXXX")
restart=0
cleanup() {
    rm -f "$temp" "$dumpdir/keycloak.dump"
    rmdir "$dumpdir"
    if (( restart )); then docker compose start siyuan; fi
}
trap cleanup EXIT
docker compose exec -T notion-id-db pg_dump -U keycloak -Fc keycloak > "$dumpdir/keycloak.dump"
if docker compose ps --status running --services | grep -qx siyuan; then
    restart=1
    docker compose stop -t 120 siyuan
    code=$(docker inspect --format '{{.State.ExitCode}}' "$(docker compose ps -aq siyuan)")
    [[ "$code" != 137 ]]
fi
optional=()
for file in mcp-access.json agent-account memory-sync-state; do
    if [[ -e "$file" ]]; then optional+=("$file"); fi
done
tar -czf "$temp" workspace compose.yaml .env brand mobile-fix mcp*.env mcp-realm.json siyuan-mcp "${optional[@]}" -C "$dumpdir" keycloak.dump
if (( restart )); then
    docker compose start siyuan
    restart=0
fi
tar -tzf "$temp" >/dev/null
mv "$temp" "$archive"
find "$store" -maxdepth 1 -name 'siyuan-*.tar.gz' -type f -mtime +7 -delete
