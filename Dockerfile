FROM debian:jessie
MAINTAINER Peter Hartmann
LABEL Description="Cutting-edge LAMP stack, based on Debain. Includes .htaccess support and popular PHP7 features, including composer and mail() function." \
        License="Apache License 2.0" \
        Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql peter-hartmann/debian-docker." \
        Version="1.0"

RUN apt-get update -qq
RUN apt-get upgrade -y

COPY assets/debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y wget
RUN wget -qO - https://www.dotdeb.org/dotdeb.gpg | apt-key add -
RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN apt-get update -qq
RUN apt-get upgrade -y

RUN apt-get install -y \
	php7.0 \
	php7.0-bz2 \
	php7.0-cgi \
	php7.0-cli \
	php7.0-common \
	php7.0-curl \
	php7.0-dev \
	php7.0-enchant \
	php7.0-fpm \
	php7.0-gd \
	php7.0-gmp \
	php7.0-imap \
	php7.0-interbase \
	php7.0-intl \
	php7.0-json \
	php7.0-ldap \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-odbc \
	php7.0-opcache \
	php7.0-pgsql \
	php7.0-phpdbg \
	php7.0-pspell \
	php7.0-readline \
	php7.0-recode \
	php7.0-snmp \
	php7.0-sqlite3 \
	php7.0-sybase \
	php7.0-tidy \
	php7.0-xmlrpc \
	php7.0-xsl \
	php7.0-mbstring
RUN apt-get install -y apache2 libapache2-mod-php7.0
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-common mariadb-server mariadb-client
RUN apt-get -y install postfix git nodejs npm nano tree vim curl ftp snmp expect
RUN npm install -g yarn grunt-cli gulp
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
#ENV TERM dumb

##https://www.linode.com/docs/email/postfix/configure-postfix-to-send-mail-using-gmail-and-google-apps-on-debian-or-ubuntu
ADD assets/postfix-sasl_passwd /etc/postfix/sasl/sasl_passwd
RUN postmap /etc/postfix/sasl/sasl_passwd &&\
    chown root:root /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db &&\
    chmod 0600 /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db &&\
	cp /etc/resolv.conf /var/spool/postfix/etc/resolv.conf #https://ubuntuforums.org/showthread.php?t=2213546 

ADD assets/postfix-main.cf /etc/postfix/main.cf

WORKDIR /root

COPY assets/index.php /var/www/html/index.php
COPY assets/run-lamp.sh /usr/sbin/
COPY assets/mysql-secure-init.sh /usr/sbin/
COPY assets/config.sh ./

RUN a2enmod rewrite
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/sbin/run-lamp.sh
RUN chmod +x /usr/sbin/mysql-secure-init.sh
RUN chmod +x ./config.sh
RUN chown -R www-data:www-data /var/www/html

VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /backup

EXPOSE 80 3306

ENTRYPOINT /usr/sbin/run-lamp.sh && bash
