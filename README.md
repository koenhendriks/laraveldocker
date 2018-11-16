# LaravelDocker
Laravel docker container with a single Dockerfile. No services needed.

This Dockerfile is available on hub.docker.com. 

### Quickstart

Use this docker as base for your own Laravel Application. Create the following `Dockerfile` in your Laravel application root:

```Dockerfile
FROM koenhendriks/laraveldocker

EXPOSE 80 443 3306
```

Now you can build and run your Laravel application easily with the following commands:

*Build*:

`docker build -t your/tag .`

*Run*:

`docker run --name=app_name -v /path/to/laravel/project/:/app/ -p 80:80 your/tag`

The container expects the laravel application to be found in `/app/`.
The Dockerfile will provide you with an Nginx server and MySQL database. The hostname of the server by default is `laravel.test`. 

Make sure to add this to your `/etc/hosts`

*Hosts*:

`127.0.0.1	laravel.test`

## Configuration

The LaravelDocker should work out of the box for most projects. If you want to change settings you can use the set environment variables.

| ENV           				| Default       | Description  |
| ----------------------------- |:-------------:| ---------------------------------------------------------------------------------:|
| TIMEZONE 						| UTC			| Sets the timezone in the container.												|
| DB_DATABASE 					| homestead		| Database table that will be created.												|
| DB_USERNAME 					| homestead		| Database user that will be created and granted all priviliges on the database.	|
| DB_PASSWORD 					| secret		| Database password that will be set for the database user. 						|
| APP_DOMAIN 					| laravel.test  | APP_DOMAIN will be used for the Nginx vhost.										|

__Custom Configuration Example__ 

```Dockerfile
FROM koenhendriks/laraveldocker

ENV APP_DOMAIN=application.test

ENV TIMEZONE=Europe\/Amsterdam
ENV DB_USERNAME=userdb
ENV DB_DATABASE=appdb
ENV DB_PASSWORD=p4ssw0rd

```

By using this configuration the application will be available on `application.test` and MySQL will have a user `userdb` who can login with the password `p4ssw0rd` and it will have access to the database table `appdb`. 


## Logs

Nginx logs are provided in `/path/to/laravel/project/storage/logs/`. 