#!/bin/sh
sed -i "s/pass/${POSTGRES_PASSWORD}/g" /root/.pgpass
sed -i "s/user/${POSTGRES_USER}/g" /root/.pgpass
chmod 600 ~/.pgpass

# start cron
/usr/sbin/crond -f -l 8
