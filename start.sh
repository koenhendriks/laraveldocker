#! /bin/bash

# Create Vhost with env variables
echo 'server {
         listen 80;
         listen [::]:80 ipv6only=on;

         # Log files for Debugging
         access_log /app/storage/logs/laravel-access-'${APP_DOMAIN}'.log;
         error_log /app/storage/logs/laravel-error-'${APP_DOMAIN}'.log;

         # Webroot Directory for Laravel project
         root /app/public;
         index index.php index.html index.htm;

         server_name '${APP_DOMAIN}';

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
 }' > /etc/nginx/sites-enabled/default;

# Create database with env variables
service mysql start;
mysql -u root -e "CREATE USER '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}';GRANT ALL PRIVILEGES ON *.* TO '${DB_USERNAME}'@'%' WITH GRANT OPTION;create database ${DB_DATABASE};";

cd /app;
chmod -R 777 storage/
chmod -R 775 bootstrap/cache/

if [ ! -f /app/.env ]; then
    cp /app/.env.example /app/.env
fi

composer install;
php artisan key:generate;
php artisan migrate:fresh --seed --force;
yarn install;
yarn run prod;
service mysql stop;


supervisord -c /etc/supervisor/conf.d/supervisord.conf;