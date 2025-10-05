#!/usr/bin/env bash

set -o errexit

if [[ -z "${ADMIN_USERNAME}" ]]; then echo "Missing ADMIN_USERNAME environment variable" >&2; exit 1; fi
if [[ -z "${ADMIN_PASSWORD}" ]]; then echo "Missing ADMIN_PASSWORD environment variable" >&2; exit 1; fi
if [[ -z "${ADMIN_EMAIL}" ]]; then echo "Missing ADMIN_EMAIL environment variable" >&2; exit 1; fi

set -o nounset

echo "Making staticfiles"
static_dir=staticfiles
mkdir -p client/dist/static
if [[ ! -d $static_dir ]] || [[ -z $(ls -A $static_dir) ]]; then
  echo "Executing collectstatic"
  python manage.py collectstatic --noinput;
fi

echo "Initializing database"
python manage.py wait_for_db
python manage.py migrate
python manage.py create_roles

echo "Creating admin"
if [[ -n "${ADMIN_USERNAME}" ]] && [[ -n "${ADMIN_PASSWORD}" ]] && [[ -n "${ADMIN_EMAIL}" ]]; then
  python manage.py create_admin \
    --username "${ADMIN_USERNAME}" \
    --password "${ADMIN_PASSWORD}" \
    --email "${ADMIN_EMAIL}" \
    --noinput \
  || true
fi

echo "Starting django on Railway"
# Railway provides PORT automatically, default to 8000 if not set
gunicorn \
  --bind="0.0.0.0:${PORT:-8000}" \
  --workers="${WORKERS:-2}" \
  --timeout=300 \
  --capture-output \
  --log-level info \
  --access-logfile - \
  --error-logfile - \
  config.wsgi &
gunicorn_pid="$!"

# Start celery worker in background for Railway
echo "Starting celery worker"
celery --app=config worker --loglevel=INFO --concurrency="${CELERY_WORKERS:-1}" &
celery_pid="$!"

# Monitor processes
while :; do
  if [[ ! -e "/proc/${celery_pid}" ]]; then
    echo "celery crashed" >&2
    exit 1
  elif [[ ! -e "/proc/${gunicorn_pid}" ]]; then
    echo "gunicorn crashed" >&2
    exit 2
  else
    sleep 10
  fi
done