# Use an official Python runtime as a parent image
FROM ubuntu:18.04

ENV TIMEZONE="Europe/Amsterdam"
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV MYSQL_USER=homestead
ENV MYSQL_PASSWORD=secret
ENV MYSQL_DATABASE=homestead

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
	php7.2-cli \
	php7.2-common \
	php7.2-mysql \
	php7.2-mbstring \
	php7.2-json \
	php7.2-xml \
	git 

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
	mv composer.phar /usr/local/bin/composer

# Install Nginx and turn off daemon
RUN apt-get install -y nginx && \
	sed -i '1idaemon off;' /etc/nginx/nginx.conf

# Install MySQL, update bind-address and create user with database
RUN apt-get install mysql-server -y && \
	sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf && \
	service mysql start && \
	mysql -u root -e \
		"CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;create database ${MYSQL_DATABASE};"

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 80 443 3306

