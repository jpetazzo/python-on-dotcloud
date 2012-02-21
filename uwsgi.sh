#!/usr/bin/env bash

/home/dotcloud/env/bin/uwsgi --single-interpreter --enable-threads --pidfile /var/dotcloud/uwsgi.pid -s /var/dotcloud/uwsgi.sock --chmod-socket=660 --master --processes 4 --home /home/dotcloud/env --pythonpath /home/dotcloud/current --disable-logging --wsgi-file /home/dotcloud/current/wsgi.py