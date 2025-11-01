# 80 포트 (Certbot 갱신 및 443 리디렉션용)
server {
    listen 80;
    server_name {YOUR_DOMAIN_HERE}; # (예: paul-ryu-0314.iptime.org)

    # Certbot 인증 경로
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # 80 포트의 나머지 모든 요청은 443(HTTPS)로 리디렉션
    location / {
        return 301 https://$host$request_uri;
    }
}