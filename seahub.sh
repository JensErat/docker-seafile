#!/bin/sh

[ "${autostart}" = 'true' -a -x /opt/seafile/seafile-server-latest/seahub.sh ] || exit 0

/opt/seafile/seafile-server-latest/seahub.sh start >>/var/log/seafile.log 2>&1

# Script should not exit unless seahub died
while pgrep -f "manage.py run_gunicorn" 2>&1 >/dev/null; do
	sleep 10;
done

exit 1
