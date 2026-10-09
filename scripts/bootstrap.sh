#!/usr/bin/env bash
# Aplica a modelagem em um MySQL já no ar, na ordem numérica.
#
#   ./scripts/bootstrap.sh
#   MYSQL_HOST=127.0.0.1 MYSQL_PORT=3310 MYSQL_PWD=root ./scripts/bootstrap.sh
set -euo pipefail

HOST="${MYSQL_HOST:-127.0.0.1}"
PORT="${MYSQL_PORT:-3306}"
USER="${MYSQL_USER:-root}"

cd "$(dirname "$0")/.."

for arquivo in sql_implementation/[0-9][0-9]_*.sql; do
  printf '%-42s' "$arquivo"
  mysql -h "$HOST" -P "$PORT" -u "$USER" --default-character-set=utf8mb4 < "$arquivo" > /dev/null
  echo 'OK'
done

echo
echo 'Pronto. O banco oficina_mecanica_refinado está criado e populado.'
