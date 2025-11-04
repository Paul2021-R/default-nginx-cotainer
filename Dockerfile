# 1. 'jc21' 공식 이미지를 기반으로 함 (Debian 기반)
FROM jc21/nginx-proxy-manager:latest

# 2. 루트 권한으로 전환하여 플러그인 설치
USER root

# 3. 'apt' (Debian)로 NoIP 플러그인 설치
RUN apt-get update && \
    apt-get install -y python3-certbot-dns-noip

# 4. 원래의 non-root 유저(1000)로 복귀
USER 1000