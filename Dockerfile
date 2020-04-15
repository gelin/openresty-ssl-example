FROM openresty/openresty:1.15.8.3-1-alpine

COPY ./certs/ /etc/nginx/certs/
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./cert.lua /etc/nginx/
