FROM ubuntu:20.04
MAINTAINER Akhil Raj

# setting up default env
ENV DEBIAN_FRONTEND=noninteractive
ENV APP_NAME=myapp
ENV CAKEPHP_VER=4.0
ENV NODEJS_VER=12
ENV PHP_VER=8.0
ENV LANG en_US.UTF-8
ENV SSH_USERNAME=""
ENV SSH_PASSWORD=""
ENV MYSQL_USERNAME=""
ENV MYSQL_PASSWORD=""
ENV MYSQL_HOST=""
ENV MYSQL_DB=""

# install dependencies
RUN apt-get update \
    && apt-get upgrade -yq \
    && apt-get install -yq --no-install-recommends \
        git \
        dirmngr \
        lsb-release \
        curl \
        locales \
        apt-utils \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && add-apt-repository ppa:ondrej/php

# install php and dependencies
RUN apt-get update \
    && apt-get install -y php${PHP_VER} \
    php${PHP_VER}-common \
    php${PHP_VER}-fpm \
    php${PHP_VER}-mysql \
    php${PHP_VER}-gmp \
    php${PHP_VER}-xml \
    php${PHP_VER}-xmlrpc \
    php${PHP_VER}-curl \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-gd \
    php${PHP_VER}-dev \
    php${PHP_VER}-imap \
    php${PHP_VER}-opcache \
    php${PHP_VER}-readline \
    php${PHP_VER}-soap \
    php${PHP_VER}-zip \
    php${PHP_VER}-intl \
    php${PHP_VER}-cli \
    libapache2-mod-php${PHP_VER}

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VER}.x | bash - \
    && apt-get -y install nodejs

# install apache2 and openssh
RUN apt-get install -yq \
        apache2 \
        openssh-server \
        openssh-client

# install cakephp
WORKDIR /var/www/html
RUN composer create-project --prefer-dist cakephp/app:~${CAKEPHP_VER} ${APP_NAME}
COPY app_local.php /opt/app_local.php

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]