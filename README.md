# docker-LNPP

<s>**THIS IS IN DEVELOPMENT**</s> This just worked the first time for me, so it's ready for the Docker universe I guess!

Development happens on branch `develop`.
The `master` will hold stable releases once I'd say I have something like that.

A Dockerfile for my idea of a LAMP stack (actually LNPP):
- [NGINX][nginx],
- [PostgreSQL][postgresql],
- [php5-fpm][php5-fpm]
- all run by [daemontools][daemontools] (or here, [runit][runit]).

Big up to [Hongli Lai](https://github.com/FooBarWidget) at [Phusion](http://www.phusion.nl/) for [baseimage-docker](https://github.com/phusion/baseimage-docker), to [Ryan Seto](https://github.com/Painted-Fox) for [adding Postgres](https://github.com/Painted-Fox/docker-postgresql) and to [Ross Riley](https://github.com/rossriley) for his [docker-nginx-pg-php](https://github.com/rossriley/docker-nginx-pg-php) which I took some good advice from.

[postgresql]: http://www.postgresql.org/
[NGINX]: http://nginx.org/
[php5-fpm]: http://php-fpm.org/
[runit]: http://smarden.org/runit/
[daemontools]: http://cr.yp.to/daemontools.html

## Image Creation

This example creates the image with the tag `hacklschorsch/lnpp`, but you can change this to use your own username.

```
$ docker build -t="hacklschorsch/lnpp" .
```

Alternately, you can just run `make` if you have GNU make installed.

You can also specify a custom docker username like so:

```
$ make DOCKER_USER=hacklschorsch
```

## Container Creation / Running

The PostgreSQL server is configured to store data in `/data/postgres` inside the container.
You can map the container's `/data` volume to a volume on the host so the data becomes independant of the running container.

When the container runs, it creates a superuser with a random password.
You can set the username and password for the superuser by setting the container's environment variables.
This lets you discover the username and password of the superuser from within a linked container or from the output of `docker inspect postgresql`.

If you set `DB=database_name`, when the container runs it will create a new
database with the USER having full ownership of it.

``` shell
$ mkdir -p /tmp/postgresql
$ docker run -d --name="postgresql" \
             -p 127.0.0.1:5432:5432 \
             -v /tmp/postgresql:/data \
             -e USER="super" \
             -e DB="database_name" \
             -e PASS="$(pwgen -s -1 16)" \
             hacklschorsch/lnpp
```

## Connecting to the Database

You'll need the password from the `docker logs` command when prompted:

``` shell
$ docker logs postgresql
POSTGRES_USER=super
POSTGRES_PASS=b2rXEpToTRoK8PBx
POSTGRES_DATA_DIR=/data
Starting PostgreSQL...
Creating the superuser: super
2014-02-07 03:30:55 UTC LOG:  database system was interrupted; last known up at 2014-02-01 07:06:21 UTC
[...]
```

[Enjoy yourselves!](http://youtu.be/nFxjnUPRwx4) ~ Florian
