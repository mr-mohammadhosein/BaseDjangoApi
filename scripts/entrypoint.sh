#!/bin/sh
set -eu

log() {
    printf '%s\n' "$*"
}

error() {
    printf 'ERROR: %s\n' "$*" >&2
}

is_true() {
    case "${1:-}" in
        1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]|[Yy]|[Oo][Nn]) return 0 ;;
        *) return 1 ;;
    esac
}

manage() {
    python manage.py "$@"
}

create_superuser() {
    if ! is_true "${CREATE_SUPERUSER:-False}"; then
        return 0
    fi

    if [ -z "${SUPERUSER_PASSWORD:-}" ]; then
        error "SUPERUSER_PASSWORD must be set when CREATE_SUPERUSER=true"
        exit 1
    fi

    log "Ensuring superuser exists..."
    python manage.py shell <<'PY'
import os

from django.contrib.auth import get_user_model

User = get_user_model()
username_field = User.USERNAME_FIELD
email_field = getattr(User, "EMAIL_FIELD", "email")
identifier = os.environ.get("SUPERUSER_USERNAME", "admin")
email = os.environ.get("SUPERUSER_EMAIL", "admin@example.com")
password = os.environ["SUPERUSER_PASSWORD"]

lookup = {username_field: identifier}

if User.objects.filter(**lookup).exists():
    print(f"Superuser {identifier} already exists.")
else:
    create_kwargs = {username_field: identifier, "password": password}
    if email and email_field != username_field and hasattr(User, email_field):
        create_kwargs[email_field] = email

    User.objects.create_superuser(**create_kwargs)
    print(f"Superuser {identifier} created successfully.")
PY
}

start_server() {
    bind_address="${DJANGO_BIND_ADDRESS:-}"
    if [ -z "$bind_address" ]; then
        bind_address="0.0.0.0:${PORT:-8000}"
    fi

    if is_true "${DEBUG:-False}"; then
        log "Starting Django development server..."
        exec python manage.py runserver "$bind_address"
    fi

    log "Starting Gunicorn production server..."
    exec gunicorn "${GUNICORN_APP:-config.wsgi:application}" \
        --bind "$bind_address" \
        --workers "${GUNICORN_WORKERS:-3}" \
        --timeout "${GUNICORN_TIMEOUT:-60}" \
        --access-logfile "${GUNICORN_ACCESS_LOGFILE:--}" \
        --error-logfile "${GUNICORN_ERROR_LOGFILE:--}" \
        --log-level "${GUNICORN_LOG_LEVEL:-info}"
}


if is_true "${RUN_MIGRATIONS:-True}"; then
    log "Applying database migrations..."
    manage migrate --noinput
fi

if is_true "${COLLECT_STATIC:-False}"; then
    log "Collecting static files..."
    manage collectstatic --noinput
fi

create_superuser

if [ "$#" -gt 0 ]; then
    log "Executing custom command: $*"
    exec "$@"
fi

start_server
