# docker-LNPP

**THIS IS IN DEVELOPMENT** and probably not ready yet.

Development happens on branch `develop`.
The `master` will hold stable releases once I'd say I have something like that.

A Dockerfile for my idea of a LAMP stack (actually LNPP):
- [NGINX][nginx],
- [PostgreSQL][postgresql],
- [php5-fpm][php5-fpm]
- all run by [daemontools][daemontools] (or here, [runit][runit]).

Big up to [Hongli Lai](https://github.com/FooBarWidget) at [Phusion](http://www.phusion.nl/) for [baseimage-docker](https://github.com/phusion/baseimage-docker), to [Ryan Seto](https://github.com/Painted-Fox) for adding Postgres and to [Ross Riley](https://github.com/rossriley) for his [docker-nginx-pg-php](https://github.com/rossriley/docker-nginx-pg-php) which I took some good advice from.

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

You can also specify a custom port to bind to on the host, a custom data
directory, and the superuser username and password on the host like so:

``` shell
$ sudo mkdir -p /srv/docker/postgresql
$ make run PORT=127.0.0.1:5432 \
           DATA_DIR=/srv/docker/postgresql \
           USER=super \
           PASS=$(pwgen -s -1 16)
```

## Connecting to the Database

To connect to the PostgreSQL server, you will need to make sure you have
a client.  You can install the `postgresql-client` on your host machine by
running the following (Ubuntu 12.04LTS):

``` shell
$ sudo apt-get install postgresql-client
```

As part of the startup for PostgreSQL, the container will generate a random
password for the superuser.  To view the login in run `docker logs
<container_name>` like so:

``` shell
$ docker logs postgresql
POSTGRES_USER=super
POSTGRES_PASS=b2rXEpToTRoK8PBx
POSTGRES_DATA_DIR=/data
Starting PostgreSQL...
Creating the superuser: super
2014-02-07 03:30:55 UTC LOG:  database system was interrupted; last known up at 2014-02-01 07:06:21 UTC
2014-02-07 03:30:55 UTC LOG:  database system was not properly shut down; automatic recovery in progress
2014-02-07 03:30:55 UTC LOG:  record with zero length at 0/17859E8
2014-02-07 03:30:55 UTC LOG:  redo is not required
2014-02-07 03:30:55 UTC LOG:  database system is ready to accept connections
2014-02-07 03:30:55 UTC LOG:  autovacuum launcher started
```

Then you can connect to the PostgreSQL server from the host with the following
command:

``` shell
$ psql -h 127.0.0.1 -U super template1
```

Then enter the password from the `docker logs` command when prompted.

