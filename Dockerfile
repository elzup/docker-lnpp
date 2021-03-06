# LNPP: Linux, NGINX, PostgreSQL, PHP.
# Note: This expects a volume at /data for postgres, nginx docroot and logs

FROM phusion/baseimage:0.9.15
MAINTAINER Florian Sesser <florian@sesser.at>


## Generic, system-wide things

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN /usr/bin/workaround-docker-2267

# Disable SSH (Not using it at the moment).
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh
# or:
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Ensure we create the cluster with UTF-8 locale
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale
# RUN dpkg-reconfigure locales

RUN apt-get update



## Postgres

RUN apt-get -y install postgresql-9.3 postgresql-contrib-9.3 pwgen

# Cofigure the database to use our data dir.
RUN sed -i -e"s/data_directory =.*$/data_directory = '\/data\/postgresql'/" /etc/postgresql/9.3/main/postgresql.conf

ADD scripts /scripts
RUN chmod +x /scripts/start.sh
RUN touch /firstrun

# Add daemon to be run by runit.
RUN mkdir /etc/service/postgresql
RUN ln -s /scripts/start.sh /etc/service/postgresql/run

# will not work for bind-mount volumes, thus
# this is replicated in the first-run script
RUN mkdir -p /data/postgresql
RUN chown -R postgres:postgres /data/postgresql


## NGINX

RUN apt-get install -y nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN mkdir -p /data/nginx_docroot
ADD config/nginx.conf /etc/nginx/sites-available/default



## PHP5

RUN apt-get install -y php5-fpm php5-pgsql php-apc php5-mcrypt php5-curl php5-gd php5-json php5-cli

# RUN sed -i -e "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size = 8M/post_max_size = 20M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 20M/g" /etc/php5/fpm/php.ini
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "max_input_vars = 10000;" >> /etc/php5/fpm/php.ini
RUN echo "date.timezone = Europe/Berlin;" >> etc/php5/fpm/php.ini




## Closing up shop.

ADD service /etc/service
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
VOLUME ["/data/", "/var/log/"]

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
