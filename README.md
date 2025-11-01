# Default-Nginx-Container 
## Outline
서버 설정을 위한 nginx template 레포지터리입니다. 
목적은 nginx 의 독립적인 설정 및 각 상황에 맞춰 진행하기 위함입니다. 

## 포함 내용
- 폴더 구조를 통한 certbot, nginx의 통합 설정 관리
- docker-compose 를 기반으로 하는 컨테이닝 방식의 관리
- HTTP, HTTPS E2E 통신을 위한 init, renew 스크립트

## 적용 방법
1. nginx_init.conf 가 nginx_target.conf 로 바꿔준다. 
2. nginx_targe.conf 를 기반으로 `docker compose up -d`
3. HTTPS 가 필요시 init-ssl 스크립트 활용, renew-ssl은 다양한 방식으로 자동화 시키면 됨. 