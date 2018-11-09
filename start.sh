#! /bin/bash

# Create Vhost with env variables
echo 'server {
         listen 80;
         listen [::]:80 ipv6only=on;

         # Log files for Debugging
         access_log /app/public/laravel-access.log;
         error_log /app/public/laravel-error.log;

         # Webroot Directory for Laravel project
         root /app/public;
         index index.php index.html index.htm;

         server_name '${APP_NAME}'.test;

         location / {
                 try_files $uri $uri/ /index.php?$query_string;
         }

         # PHP-FPM Configuration Nginx
         location ~ \.php$ {
                 try_files $uri =404;
                 fastcgi_split_path_info ^(.+\.php)(/.+)$;
                 fastcgi_pass unix:/run/php/php7.2-fpm.sock;
                 fastcgi_index index.php;
                 fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                 include fastcgi_params;
         }
 }' > /etc/nginx/sites-enabled/laravel;

# Create database with env variables
service mysql start;
mysql -u root -e "CREATE USER '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}';GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'%' WITH GRANT OPTION;create database ${DB_DATABASE};";
service mysql stop;

composer install;
php artisan key:generate;
php artisan migrate;
php artisan seed;

supervisord -c /etc/supervisor/conf.d/supervisord.conf;