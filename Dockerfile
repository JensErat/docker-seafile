FROM		phusion/baseimage
MAINTAINER	Jens Erat <email@jenserat.de>

ENV DEBIAN_FRONTEND noninteractive

# Seafile dependencies and system configuration
RUN apt-get update && \
    apt-get install -y python2.7 python-setuptools python-simplejson python-imaging sqlite3 python-mysqldb python-memcache python-urllib3 wget socat
RUN ulimit -n 30000

# Interface the environment
RUN mkdir /opt/seafile
VOLUME /opt/seafile
EXPOSE 10001 12001 8000 8080 8082

# Baseimage init process
ENTRYPOINT ["/sbin/my_init"]

# Seafile daemons
RUN mkdir /etc/service/seafile /etc/service/seahub
ADD seafile.sh /etc/service/seafile/run
ADD seahub.sh /etc/service/seahub/run

ADD download-seafile.sh /usr/local/sbin/download-seafile

# Clean up for smaller image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
