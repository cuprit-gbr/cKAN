FROM alpine:3.10.9

RUN apk update
RUN apk add --no-cache curl bash postgresql-client rsync

# Add Notifications script
COPY scripts/send_notifications /etc/periodic/15min
RUN chmod +x /etc/periodic/15min/send_notifications

# Add Backup script
COPY scripts/backup /etc/periodic/daily
RUN chmod +x /etc/periodic/daily/backup

# Add postgres auth file
COPY scripts/pgpass.txt /root/.pgpass

# Add entrypoint
COPY scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
