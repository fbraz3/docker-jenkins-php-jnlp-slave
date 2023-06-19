FROM jenkins/inbound-agent

ARG PHP_VERSION=7.4

USER root

#OS base packages
RUN apt-get update; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt -yq install lsb-release apt-transport-https ca-certificates wget zip unrar-free unzip curl less git gettext;

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg; \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list; \
    apt update;

## php-base
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get install -yq php$PHP_VERSION php$PHP_VERSION-cli \
    php$PHP_VERSION-common php$PHP_VERSION-curl php$PHP_VERSION-fpm \
    php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-readline \
    php$PHP_VERSION-xml php$PHP_VERSION-xsl php$PHP_VERSION-gd php$PHP_VERSION-intl \
    php$PHP_VERSION-bz2 php$PHP_VERSION-bcmath php$PHP_VERSION-imap php$PHP_VERSION-gd \
    php$PHP_VERSION-mbstring php$PHP_VERSION-pgsql php$PHP_VERSION-sqlite3 \
    php$PHP_VERSION-xmlrpc php$PHP_VERSION-zip php$PHP_VERSION-odbc php$PHP_VERSION-snmp \
    php$PHP_VERSION-interbase php$PHP_VERSION-ldap php$PHP_VERSION-tidy \
    php$PHP_VERSION-memcached php$PHP_VERSION-redis php$PHP_VERSION-imagick php$PHP_VERSION-mongodb; \
#    if [ $PHP_VERSION \< 8 ]; then \
#      apt-get install -yq php$PHP_VERSION-json; \
#    fi;

## INSTALL xdebug
RUN apt update && \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get install -yq php$PHP_VERSION-xdebug

## MySQL CLient
RUN export DEBIAN_FRONTEND=noninteractive; apt-get install -yq mariadb-client

## Install composer
RUN if [ $PHP_VERSION \> 7.3 ]; then \
      apt-get install -yq libpcre2-8-0; \
    fi; \
    mkdir /opt/composer; \
    cd /opt/composer && ( \
        wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O - -q | php -- --quiet; \
        ln -s /opt/composer/composer.phar /usr/local/bin/composer; \
    )

## Install Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv $HOME/.symfony5/bin/symfony /usr/local/bin/symfony

USER jenkins
