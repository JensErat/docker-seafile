# Seafile 4 for Docker

[Seafile](http://www.seafile.com/) is a "next-generation open source cloud storage
with advanced features on file syncing, privacy protection and teamwork".

This Dockerfile does not really package Seafile 4 for Docker, but provides an environment for running it including startup scripts, including all dependencies for both a SQLite or MySQL (requires external MySQL database, for example in another container) setup.

## Setup

The image only prepares the base system and provides some support during installation. [Read through the setup manual](https://github.com/haiwen/seafile/wiki/Download-and-setup-seafile-server) before setting up Seafile.

Run the image in a container, exposing ports as needed and making `/opt/seafile` permanent. For setting seafile up, maintaining its configuration or performing updates, make sure to start a shell. As the image builds on [`phusion/baseimage`](https://github.com/phusion/baseimage-docker), do so by attaching `-- /bin/bash` as parameter.


For example, you could use

    docker run -t -i \
      -p 10001:10001 \
      -p 12001:12001 \
      -p 8000:8000 \
      -p 8080:8080 \
      -p 8082:8082 \
      -v /srv/seafile:/opt/seafile \
      jenserat/seafile -- /bin/bash

Consider using a reverse proxy for using HTTPs.

1. After the container is started, run `download-seafile` to download Seafile and prepare setting it up.
2. Once downloaded, run `/opt/seafile/seafile-server-4.*/setup-seafile.sh`, and go through the setup assistant. Do not change the port and storage location defaults, but change the run command appropriately.
3. Run `/opt/seafile/seafile-server-latest/seahub.sh start` for configuring the web UI.
4. If you want, do more configuration of Seafile. You can also already try it out.
5. Setting up Seafile is finished, `exit` the container.

In case you want to use memcached instead of /tmp/seahub_cache/ add the following to your seahub_settings.py

    CACHES = {
      'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'memcached:11211',
      }
    }

Link your memcached instance to your seafile container by adding `--link memcached_container:memcached` to your docker run statement.

## Running Seafile

Run the image again, this time you probably want to give it a name for using some startup scripts. You will not need an interactive shell for normal operation. **The image will autostart the `seafile` and `seahub` processes if the environment variable `autostart=true` is set.** A reasonable docker command is

    docker run -d \
      --name seafile \
      -p 10001:10001 \
      -p 12001:12001 \
      -p 8000:8000 \
      -p 8080:8080 \
      -p 8082:8082 \
      -v /srv/seafile:/opt/seafile \
      -e autostart=true \
      jenserat/seafile

For proxying Seafile using nginx, enable FastCGI by adding `-e fastcgi=true`.

## Updates and Maintenance

The Seafile binaries are stored in the permanent volume `/opt/seafile`. To update the base system, just stop and drop the container, update the image using `docker pull jenserat/seafile` and run it again. To update Seafile, follow the normal upgrade process described in the [Seafile upgrade manual](https://github.com/haiwen/seafile/wiki/Upgrading-Seafile-Server). `download-seafile` might help you with the first steps if already updated to the newest version.

## Workaround for [Seafile issue #478](https://github.com/haiwen/seafile/issues/478)

If used in FastCGI mode, like [recommended when proxying WebDAV](http://manual.seafile.com/extension/webdav.html#sample-configuration-2-with-nginxapache), seafdav only listens on `localhost:8080`; with consequence that it cannot be exposed. The image has a workaround built-in, which uses `socat` listening on `0.0.0.0:8080`, forwarding to `localhost:8081`. To use it, modify `/opt/seafile/conf/seafdav.conf` and change the `port` to `8081`, and restart the container enabling the workaround using `-e workaround478=true`.
