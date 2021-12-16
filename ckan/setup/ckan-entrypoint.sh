#!/bin/sh
set -e

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${CKAN_SQLALCHEMY_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}
# URL for datapusher (required unless linked to a container called 'datapusher')
: ${CKAN_DATAPUSHER_URL:=}

CONFIG="${CKAN_CONFIG}/production.ini"

abort () {
  echo "$@" >&2
  exit 1
}

set_environment () {
  export CKAN_SITE_ID=${CKAN_SITE_ID}
  export CKAN_SITE_URL=${CKAN_SITE_URL}
  export CKAN_SQLALCHEMY_URL=${CKAN_SQLALCHEMY_URL}
  export CKAN_SOLR_URL=${CKAN_SOLR_URL}
  export CKAN_REDIS_URL=${CKAN_REDIS_URL}
  export CKAN_STORAGE_PATH=/var/lib/ckan
  export CKAN_DATAPUSHER_URL=${CKAN_DATAPUSHER_URL}
  export CKAN_DATASTORE_WRITE_URL=${CKAN_DATASTORE_WRITE_URL}
  export CKAN_DATASTORE_READ_URL=${CKAN_DATASTORE_READ_URL}
  export CKAN_SMTP_SERVER=${CKAN_SMTP_SERVER}
  export CKAN_SMTP_STARTTLS=${CKAN_SMTP_STARTTLS}
  export CKAN_SMTP_USER=${CKAN_SMTP_USER}
  export CKAN_SMTP_PASSWORD=${CKAN_SMTP_PASSWORD}
  export CKAN_SMTP_MAIL_FROM=${CKAN_SMTP_MAIL_FROM}
  export CKAN_MAX_UPLOAD_SIZE_MB=${CKAN_MAX_UPLOAD_SIZE_MB}
}

write_config () {
  echo "Generating config at ${CONFIG}..."
  ckan generate config "$CONFIG"
}

# Wait for PostgreSQL
while ! pg_isready -h db -U ckan; do
  sleep 1;
done

# If we don't already have a config file, bootstrap
if [ ! -e "$CONFIG" ]; then
  write_config
fi

# Get or create CKAN_SQLALCHEMY_URL
if [ -z "$CKAN_SQLALCHEMY_URL" ]; then
  abort "ERROR: no CKAN_SQLALCHEMY_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_SOLR_URL" ]; then
    abort "ERROR: no CKAN_SOLR_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_REDIS_URL" ]; then
    abort "ERROR: no CKAN_REDIS_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_DATAPUSHER_URL" ]; then
    abort "ERROR: no CKAN_DATAPUSHER_URL specified in docker-compose.yml"
fi

set_environment

# init db
echo "Initializating CKAN db"
ckan --config "$CONFIG" db init

# create sysadmin user
if ckan --config "$CONFIG" user show ${CKAN_SYSADMIN_NAME} | grep -q 'User: None'; then
    echo "Creating sysadmin user"
    ckan --config "$CONFIG" user add ${CKAN_SYSADMIN_NAME} email=${CKAN_SYSADMIN_EMAIL} name=${CKAN_SYSADMIN_NAME} password=${CKAN_SYSADMIN_PASSWORD}
    ckan --config "$CONFIG" sysadmin add ${CKAN_SYSADMIN_NAME}
    # generate API token, this will be shared via a volume with ckan_service
    ckan --config "$CONFIG" user token add ${CKAN_SYSADMIN_NAME} startup_created > /usr/share/api_share/token
fi

# update plugins
echo "Loading the following plugins: ${CKAN__PLUGINS}"
ckan config-tool "$CONFIG" "ckan.plugins = ${CKAN__PLUGINS}"

# setup datastore permissions
echo "Setting up datastore database"
ckan --config "$CONFIG" datastore set-permissions >> datastore_permissions.sql
psql -Atx ${CKAN_DATASTORE_WRITE_URL} -f datastore_permissions.sql -o psql_set_datastore_permissions.log

exec "$@"
