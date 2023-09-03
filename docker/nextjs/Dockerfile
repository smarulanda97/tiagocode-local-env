FROM node:18-alpine

LABEL author="Santiago Marulanda <smarulanda97@outlook.com>"

ARG NODE_ENV=development
ENV NODE_ENV=${WATCHPACK_POLLING}

ARG WATCHPACK_POLLING=false
ENV WATCHPACK_POLLING=${WATCHPACK_POLLING}

ARG CHOKIDAR_USEPOLLING=false
ENV CHOKIDAR_USEPOLLING=${CHOKIDAR_USEPOLLING}

WORKDIR /app

RUN apk update &&  \
    apk add --no-cache bash

ADD ./startup.sh /opt/startup.sh

RUN sed -i 's/\r//g' /opt/startup.sh

CMD ["/bin/bash", "/opt/startup.sh"]

EXPOSE 3000



