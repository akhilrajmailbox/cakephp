#!/bin/bash

function sshConfig() {
    if [[ ! -z ${SSH_USERNAME} ]] && [[ ! -z ${SSH_PASSWORD} ]] ; then
        useradd -m -d /home/${SSH_USERNAME} -s /bin/bash ${SSH_USERNAME}
        echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
    else
        echo -e "\n SSH_USERNAME or SSH_PASSWORD missing...!\n SSH user won't configure"
    fi
}

function apache2Config() {
    sshConfig
    if [[ ! -z ${APP_NAME} ]] ; then
        # RUN sed -i "s|index.html|index.php|g" /etc/apache2/mods-available/dir.conf
        sed -i "s|/var/www/html|/var/www/html/${APP_NAME}/webroot|g" /etc/apache2/sites-available/*.conf
        sed -i "s|/var/www/html|/var/www/html/${APP_NAME}/webroot|g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
        rm -rf /var/www/html/index.html
    else
        echo -e "\n APP_NAME missing...!\n apache2 site won't configure"
        exit 1
    fi
}

function cakePhpConfig() {
    apache2Config
    if [[ -f /opt/app_local.php ]] && [[ ! -z ${MYSQL_HOST} ]] && [[ ! -z ${MYSQL_DB} ]] && [[ ! -z ${MYSQL_USERNAME} ]] && [[ ! -z ${MYSQL_PASSWORD} ]] ; then
        cp -f /opt/app_local.php /var/www/html/myapp/config/app_local.php
        # SEC_SALT=$(tr -dc a-z0-9 </dev/urandom | head -c 64)
        SEC_SALT="3xgzi5pls6eewbs821hihmfz6ay1sqk4p6ecdwi9zx8dbpd9e0jvztbr86r4ypbc"
        sed -i "s|SEC_SALT|${SEC_SALT}|g" /var/www/html/myapp/config/app_local.php
        sed -i "s|MYSQL_HOST|${MYSQL_HOST}|g" /var/www/html/myapp/config/app_local.php
        sed -i "s|MYSQL_DB|${MYSQL_DB}|g" /var/www/html/myapp/config/app_local.php
        sed -i "s|MYSQL_USERNAME|${MYSQL_USERNAME}|g" /var/www/html/myapp/config/app_local.php
        sed -i "s|MYSQL_PASSWORD|${MYSQL_PASSWORD}|g" /var/www/html/myapp/config/app_local.php
    else
        echo -e "\n MYSQL_HOST or MYSQL_DB or MYSQL_USERNAME or MYSQL_PASSWORD or file : /opt/app_local.php missing...!\n Datasource user won't configure"
        exit 1
    fi
}

function start() {
    cakePhpConfig
    /etc/init.d/ssh restart & wait
    a2enmod rewrite
    apachectl -D FOREGROUND
    # tail -f /entrypoint.sh
}


start