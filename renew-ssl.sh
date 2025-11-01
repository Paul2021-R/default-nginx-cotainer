#!/bin/sh

# 스크립트가 위치한 디렉터리로 이동
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || { echo "Error: Failed to change directory"; exit 1; }

echo "--- (1 / 2) Certbot Renewal Process ---"

if ! docker compose run --rm certbot renew; then
    echo "Error: Certbot renewal failed"
    exit 1
fi

echo "--- (2 / 2) Nginx Setting Reload ---"

if ! docker compose exec nginx nginx -s reload; then
    echo "Error: Nginx reload failed"
    exit 1
fi

echo "--- Renewal Finished ---"