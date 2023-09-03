FROM traefik:latest

LABEL author="Mahmoud Zalt <mahmoud@zalt.me>"
LABEL maintainer="Santiago Marulanda <smarulanda97@outlook.com>"

WORKDIR /data

RUN touch acme.json

RUN chmod 600 acme.json

VOLUME /data
