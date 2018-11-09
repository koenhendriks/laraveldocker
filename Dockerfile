# Use an official Python runtime as a parent image
FROM ubuntu:18.04

ENV TIMEZONE=Europe\/Amsterdam
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV DB_USERNAME=homestead
ENV DB_PASSWORD=secret
ENV DB_DATABASE=homestead

ENV APP_NAME=laravel

MAINTAINER Koen Hendriks <info@koenhendriks.com>

# Update packages
RUN apt-get update -y && apt-get upgrade -y

# Install basic packages
RUN apt-get install -y tzdata \
	curl \
	supervisor

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
	git  && \
	mkdir /run/php

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer

# Install MySQL, update bind-address and create user with database
RUN apt-get install mysql-server -y && \
	sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf && \
	service mysql start && \
	mysql -u root -e \
		"CREATE USER '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}';GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'%' WITH GRANT OPTION;create database ${DB_DATABASE};"

# Install Nginx, create app directory and turn off daemon
RUN apt-get install -y nginx && \
	sed -i '1idaemon off;' /etc/nginx/nginx.conf

# Install vhosts for laravel application
RUN echo "server {\n         listen 80;\n         listen [::]:80 ipv6only=on;\n \n         # Log files for Debugging\n         access_log /app/public/laravel-access.log;\n         error_log /app/public/laravel-error.log;\n \n         # Webroot Directory for Laravel project\n         root /app/public;\n         index index.php index.html index.htm;\n \n         server_name ${APP_NAME}.test;\n \n         location / {\n                 try_files \$uri \$uri/ /index.php?\$query_string;\n         }\n \n         # PHP-FPM Configuration Nginx\n         location ~ \.php\$ {\n                 try_files \$uri =404;\n                 fastcgi_split_path_info ^(.+\.php)(/.+)\$;\n                 fastcgi_pass unix:/run/php/php7.2-fpm.sock;\n                 fastcgi_index index.php;\n                 fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n                 include fastcgi_params;\n         }\n }" > /etc/nginx/sites-enabled/laravel

COPY . /app/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 80 443 3306

