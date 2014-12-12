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

# Install the latest postgresql
RUN apt-get -y install postgresql-9.3 \
                       postgresql-contrib-9.3 \
                       pwgen \
                       inotify-tools

# Install other tools.
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen inotify-tools

# Cofigure the database to use our data dir.
RUN sed -i -e"s/data_directory =.*$/data_directory = '\/data\/postgresql'/" /etc/postgresql/9.3/main/postgresql.conf

ADD scripts /scripts
RUN chmod +x /scripts/start.sh
RUN touch /firstrun

# Add daemon to be run by runit.
RUN mkdir /etc/service/postgresql
RUN ln -s /scripts/start.sh /etc/service/postgresql/run

RUN mkdir -p /data/postgresql
RUN chown -R postgres:postgres /data/postgresql


# Install nginx
# RUN apt-get install -y nginx
# RUN echo "daemon off;" >> /etc/nginx/nginx.conf

## Closing up shop.

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
