#!/bin/sh
sleep 10
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic
supervisord --nodaemon --configuration /etc/supervisord.conf