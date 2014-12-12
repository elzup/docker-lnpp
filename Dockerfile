# LNPP: Linux, NGINX, PostgreSQL, PHP.

FROM phusion/baseimage:0.9.13
MAINTAINER Florian Sesser <florian@sesser.at>


## Generic, system-wide things

# Disable SSH (Not using it at the moment).
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh



## Postgres

# Ensure we create the cluster with UTF-8 locale
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Install the latest postgresql
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
        postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 && \
    /etc/init.d/postgresql stop

# Install other tools.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen inotify-tools

# Cofigure the database to use our data dir.
RUN sed -i -e"s/data_directory =.*$/data_directory = '\/data\/postgresql'/" /etc/postgresql/9.3/main/postgresql.conf

ADD scripts /scripts
RUN chmod +x /scripts/start.sh
RUN touch /firstrun

# Add daemon to be run by runit.
RUN mkdir /etc/service/postgresql
RUN ln -s /scripts/start.sh /etc/service/postgresql/run



## Closing up shop.

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose our data, log, and configuration directories.
VOLUME ["/data"]

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
