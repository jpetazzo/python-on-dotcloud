#!/usr/bin/env bash

# check if they have newrelic enabled, if so then set it up
if test "$SERVICE_NEWRELIC_LICENSE_KEY" ; then
    NEW_RELIC_CONFIG_FILE=/home/dotcloud/current/newrelic.ini
    export NEW_RELIC_CONFIG_FILE
    command="/home/dotcloud/env/bin/newrelic-admin run-program "
else
    command=""
fi

# this assumes that your wsgi file is called wsgi.py and lives in /home/dotcloud/current/
command=$command"/home/dotcloud/env/bin/uwsgi --single-interpreter --enable-threads --pidfile /var/dotcloud/uwsgi.pid -s /var/dotcloud/uwsgi.sock --chmod-socket=660 --master --processes 4 --home /home/dotcloud/env --pythonpath /home/dotcloud/current --disable-logging --wsgi-file /home/dotcloud/current/wsgi.py"

# exeute the command
$command