# Use an official Python runtime as a parent image
FROM ubuntu:18.04

ENV TIMEZONE=Europe\/Amsterdam
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV DB_USERNAME=homestead
ENV DB_PASSWORD=secret
ENV DB_DATABASE=homestead

ENV APP_DOMAIN=laravel.test

MAINTAINER Koen Hendriks <info@koenhendriks.com>

# Update packages
RUN apt-get update -y && apt-get upgrade -y

# Install basic packages
RUN apt-get install -y tzdata \
	curl \
	supervisor \
	zip \
	unzip

# Set the timezone
RUN echo $TIMEZONE > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

# Install PHP and Git
RUN apt-get install -y \
	php7.2-fpm \
	php7.2-cli \
	php7.2-common \
	php7.2-mysql \
	php7.2-mbstring \
	php7.2-json \
	php7.2-xml \
	php7.2-bcmath \
	php7.2-curl \
	gnupg \
	git  && \
	mkdir /run/php

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer

# Install NodeJS & Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
	apt-get install -y nodejs yarn


# Install MySQL, update bind-address
RUN apt-get install mysql-server -y && \
	sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Install Nginx, create app directory and turn off daemon
RUN apt-get install -y nginx && \
	sed -i '1idaemon off;' /etc/nginx/nginx.conf

COPY ./start.sh /run/

RUN chmod +x /run/start.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/bin/bash", "/run/start.sh"]

EXPOSE 80 443 3306

