FROM alpine:3.7

# Add Notifications script
COPY scripts/send_notifications /etc/periodic/15min
RUN chmod +x /etc/periodic/15min/send_notifications

# Add entrypoint
COPY scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
