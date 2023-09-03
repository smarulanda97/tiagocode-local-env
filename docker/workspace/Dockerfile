ARG LARADOCK_PHP_VERSION
ARG BASE_IMAGE_TAG_PREFIX=latest

FROM laradock/workspace:${BASE_IMAGE_TAG_PREFIX}-${LARADOCK_PHP_VERSION}

LABEL author="Mahmoud Zalt <mahmoud@zalt.me>"
LABEL maintainer="Santiago Marulanda <smarulanda97@outlook.com>"

ARG TZ=UTC
ARG PUID=1000
ARG PGID=1000
ARG LARADOCK_PHP_VERSION
ARG COMPOSER_VERSION=2
ARG NODE_VERSION=node
ARG PHP_VERSION=${LARADOCK_PHP_VERSION}
ARG INSTALL_NODE=false
ARG INSTALL_BZ2=false
ARG INSTALL_GMP=false
ARG INSTALL_GNUPG=false
ARG INSTALL_SSH2=false
ARG INSTALL_SOAP=false
ARG INSTALL_XSL=false
ARG INSTALL_PHPDBG=false
ARG INSTALL_PHPREDIS=false
ARG INSTALL_MEMCACHED=false
ARG INSTALL_XMLRPC=false
ARG INSTALL_PHPDECIMAL=false

ENV TZ ${TZ}
ENV PUID ${PUID}
ENV PGID ${PGID}
ENV DEBIAN_FRONTEND noninteractive
ENV NVM_DIR /home/laradock/.nvm
ENV COMPOSER_VERSION ${COMPOSER_VERSION}
ENV NODE_VERSION ${NODE_VERSION}

###########################################################################
# Laradock non-root user and Set Timezone
###########################################################################

USER root

RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    groupadd -g ${PGID} laradock && \
    useradd -l -u ${PUID} -g laradock -m laradock -G docker_env && \
    usermod -p "*" laradock -s /bin/bash && \
    apt-get install -yqq apt-utils libzip-dev zip unzip php${LARADOCK_PHP_VERSION}-zip nasm && \
    php -m | grep -q 'zip' && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

###########################################################################
# Composer:
###########################################################################

USER root

COPY ./composer.json /home/laradock/.composer/composer.json

RUN chown -R laradock:laradock /home/laradock/.composer && \
    echo "" >> ~/.bashrc &&  \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc && \
    set -eux; \
    if [ "$COMPOSER_VERSION" = "1" ] || [ "$COMPOSER_VERSION" = "2" ]; then \
        composer self-update --${COMPOSER_VERSION}; \
    else \
        composer self-update ${COMPOSER_VERSION}; \
    fi

###########################################################################
# Non-root user : PHPUnit path, composer path
###########################################################################

USER laradock

RUN echo "" >> ~/.bashrc && echo 'export PATH="~/.composer/vendor/bin:$PATH"' >> ~/.bashrc && \
    echo "" >> ~/.bashrc && echo 'export PATH="/var/www/vendor/bin:$PATH"' >> ~/.bashrc

###########################################################################
# Crontab
###########################################################################

USER root

COPY ./crontab /etc/cron.d

RUN chmod -R 644 /etc/cron.d

###########################################################################
# PHP extensions
###########################################################################

USER root

RUN set -eux; \
    if [ ${INSTALL_BZ2} = true ]; then \
        apt-get -yqq install php${LARADOCK_PHP_VERSION}-bz2; \
    fi; \
    if [ ${INSTALL_GMP} = true ]; then \
        apt-get -yqq install php${LARADOCK_PHP_VERSION}-gmp; \
    fi; \
    if [ ${INSTALL_GNUPG} = true ]; then \
        apt-get -yqq install php${LARADOCK_PHP_VERSION}-gnupg; \
    fi; \
    if [ ${INSTALL_SSH2} = true ]; then \
        apt-get -yqq install libssh2-1-dev php${LARADOCK_PHP_VERSION}-ssh2; \
    fi; \
    if [ ${INSTALL_SOAP} = true ]; then \
        apt-get -yqq install libxml2-dev php${LARADOCK_PHP_VERSION}-soap; \
    fi; \
    if [ ${INSTALL_XSL} = true ]; then \
        apt-get -yqq install libxslt-dev php${LARADOCK_PHP_VERSION}-xsl; \
    fi; \
    if [ ${INSTALL_PHPDBG} = true ]; then \
        apt-get install -y --force-yes php${LARADOCK_PHP_VERSION}-phpdbg; \
    fi; \
    if [ ${INSTALL_PHPREDIS} = true ]; then \
        apt-get update && apt-get install -yqq php${LARADOCK_PHP_VERSION}-redis; \
    fi; \
    if [ ${INSTALL_MEMCACHED} = true ]; then \
        apt-get -y install php${LARADOCK_PHP_VERSION}-igbinary && apt-get -y install php${LARADOCK_PHP_VERSION}-memcached; \
    fi; \
    if [ ${INSTALL_XMLRPC} = true ]; then \
        apt-get install -yqq php${LARADOCK_PHP_VERSION}-xmlrpc; \
    fi; \
    if [ ${INSTALL_PHPDECIMAL} = true ] && ! [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
        apt-get install -yqq libmpdec-dev pecl install decimal &&  \
        echo "extension=decimal.so" >> /etc/php/${LARADOCK_PHP_VERSION}/mods-available/decimal.ini &&  \
        ln -s /etc/php/${LARADOCK_PHP_VERSION}/mods-available/decimal.ini /etc/php/${LARADOCK_PHP_VERSION}/cli/conf.d/30-decimal.ini && \
        php -m | grep -q 'decimal'; \
    fi

###########################################################################
# Node / NVM:
###########################################################################

RUN if [ ${INSTALL_NODE} = true ]; then \
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias ${NODE_VERSION} && \
    npm cache clear --force; \
fi

RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc; \
fi

# Add NVM binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/laradock/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc; \
fi

RUN if [ ${INSTALL_NODE} = true ]; then \
    find $NVM_DIR -type f -name node -exec ln -s {} /usr/local/bin/node \; && \
    NODE_MODS_DIR="$NVM_DIR/versions/node/$(node -v)/lib/node_modules" && \
    ln -s $NODE_MODS_DIR/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s $NODE_MODS_DIR/npm/bin/npx-cli.js /usr/local/bin/npx; \
fi

COPY ./.npmrc /root/.npmrc
COPY ./.npmrc /home/laradock/.npmrc

###########################################################################
# Final Touch and Check PHP version
###########################################################################

USER root

RUN apt-get clean &&  \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* &&  \
    rm -f /var/log/lastlog /var/log/faillog && \
    set -xe; php -v | head -n 1 | grep -q "PHP ${LARADOCK_PHP_VERSION}."

WORKDIR /var/www
