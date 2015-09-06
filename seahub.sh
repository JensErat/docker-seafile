#!/bin/bash

log=/var/log/seafile.log

function stop_server() {
  ps ax | grep run_gunicorn | awk '{ print $1 }' | xargs kill
}

trap stop_server SIGINT SIGTERM

[[ "${autostart}" =~ [Tt]rue && -x /opt/seafile/seafile-server-latest/seahub.sh ]] || exit 0

if [[ "${fastcgi}" =~ [Tt]rue ]]
then
    SEAFILE_FASTCGI_HOST='0.0.0.0' /opt/seafile/seafile-server-latest/seahub.sh start-fastcgi >> $log
else
    /opt/seafile/seafile-server-latest/seahub.sh start >> $log 2>&1
fi

# Script should not exit unless seahub died
while pgrep -f "manage.py run_gunicorn" 2>&1 >/dev/null; do
    sleep 5;
done

exit 0
