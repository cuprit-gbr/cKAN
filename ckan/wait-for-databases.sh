#!/bin/bash

set -e

host="$1"
shift

until PGPASSWORD=${POSTGRES_PASSWORD} psql -h "$host" -U ${POSTGRES_USER} -P "pager=off" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

until PGPASSWORD=${POSTGRES_PASSWORD} psql -h "$host" -U ${POSTGRES_USER} -d "datastore" -P "pager=off" -c '\l'; do
  >&2 echo "datastore is unavailable - sleeping"
  sleep 1
done

>&2 echo "cKAN databases are up - executing command"
