#!/bin/sh

# -e: 스크립트 실행 중 오류 발생 시 즉시 중단
set -e

# --- 0. 스크립트 위치로 이동 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || { echo "Error: Failed to change directory"; exit 1; }

# --- 0. 사용자 정보 입력 받기 ---
echo "Enter your domain name (e.g., your.domain.com):"
read -r DOMAIN

echo "Enter your email for Let's Encrypt registration:"
read -r EMAIL

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Error: Domain and Email are required."
    exit 1
fi

echo "--- (1 / 4) Preparing Nginx for initial authentication... ---"
# '임시' 80 포트 설정을 타겟 파일로 복사
cp ./nginx/nginx-init.conf ./nginx/nginx_target.conf

echo "--- (2 / 4) Starting Nginx container... ---"
# Nginx 컨테이너를 '임시' 설정으로 시작
docker compose up -d nginx

echo "--- (3 / 4) Requesting new SSL certificate for $DOMAIN... ---"
# docker compose 'run'으로 certbot 'certonly' 명령어 실행
if ! docker compose run --rm certbot certonly \
    --webroot \
    -w /var/www/certbot \
    -d "$DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --non-interactive; then
    
    echo "Error: Certbot failed to issue a certificate."
    echo "Stopping Nginx..."
    docker compose down
    exit 1
fi

echo "--- (4 / 4) Switching Nginx to final SSL configuration... ---"
# '최종' SSL 설정을 타겟 파일로 덮어쓰기
cp ./nginx/nginx-ssl.conf ./nginx/nginx_target.conf

# SSL 설정이 적용되도록 Nginx 리로드
if ! docker compose exec nginx nginx -s reload; then
    echo "Error: Nginx reload failed"
    exit 1
fi

echo "--- Initialization Finished Successfully! ---"
echo "Your site $DOMAIN is now served over HTTPS."
echo "Please set up crontab with renew-ssl.sh for auto-renewal."