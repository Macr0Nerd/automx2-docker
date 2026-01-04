#!/usr/bin/env bash

echo "This is an unofficial community maintained docker container for automx2"
echo "Please report all issues to https://github.com/mac0nerd/automx2-docker"

set -x

export FLASK_ENV=${AUTOMX2_ENV:-production}
export FLASK_APP=automx2.server:app

cd /var/www/automx2
.venv/bin/flask run --host="${AUTOMX2_HOST}" --port="${AUTOMX2_PORT}" &

until curl http://127.0.0.1:"${AUTOMX2_PORT}"
do
  sleep 5
done

if [ ! -f .initialize ]
then
  echo "Persistent configuration detected; database will not be reinitialized"
elif [ -a /etc/automx2/provider.json ]
then
  echo "Initializing database from /etc/automx2/provider.json"

  curl -X POST --json @/etc/automx2/provider.json \
    http://127.0.0.1:"${AUTOMX2_PORT}"/initdb/

  rm .initialize
else
  echo "Initializing database with sample data"

  url -X POST --json http://127.0.0.1:"${AUTOMX2_PORT}"/initdb/

  rm .initialize
fi

wait