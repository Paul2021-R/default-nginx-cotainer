#!/bin/sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || { echo "Error: Failed to change directory"; exit 1; }

# --- 0. 이메일만 입력 받기 ---
echo "Enter your email for Let's Encrypt registration:"
read -r EMAIL
if [ -z "$EMAIL" ]; then
    echo "Error: Email is required."
    exit 1
fi

# --- 1. 임시 Nginx 설정 적용 ---
# echo "--- (1 / 4) Preparing Nginx for initial authentication... ---"
# Nginx 설정 파일 복사 (이 파일은 이미 4개 도메인을 server_name에 포함)
# cp ./nginx/nginx-init.conf ./nginx/nginx_target.conf

# echo "--- (2 / 4) Starting Nginx container... ---"
# docker compose up -d nginx

echo "--- (3 / 4) Requesting new SSL certificate for 4 domains... ---"
# [수정됨] 4개 도메인을 -d 옵션으로 모두 나열
if ! docker compose run --rm certbot certonly \
    --webroot \
    -w /var/www/certbot \
    -d ryu93-jenkins.duckdns.org \
    -d ryu93-admin.duckdns.org \
    -d ryu93-n8n.duckdns.org \
    -d ryu93-storage.duckdns.org \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --non-interactive; then
    
    echo "Error: Certbot failed to issue a certificate."
    docker compose down
    exit 1
fi

echo "--- (4 / 4) Switching Nginx to final SSL configuration... ---"
# cp ./nginx/nginx-ssl.conf ./nginx/nginx_target.conf
docker compose exec nginx nginx -s reload

echo "--- Initialization Finished Successfully! ---"