FROM python:3.11-slim-bookworm AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
    && python -m venv "$VIRTUAL_ENV" \
    && pip install --upgrade pip setuptools wheel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements/ ./requirements/
RUN pip install -r requirements/prod.txt

FROM python:3.11-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl \
       dumb-init \
       gettext \
       libpq5 \
    && groupadd --system appuser \
    && useradd --system --gid appuser --home-dir /app --shell /usr/sbin/nologin appuser \
    && mkdir -p /app \
    && chown appuser:appuser /app \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appuser . .

# Build-time env vars (safe defaults for collectstatic during build)
ENV SECRET_KEY='build-time-fake-key' \
    DEBUG='False' \
    DB_HOST='build-time-fake-db-host' \
    DB_NAME='fake' \
    DB_USER='fake' \
    DB_PASSWORD='fake' \
    DB_PORT='1234' \
    USE_MINIO='False' \
    USE_SQLITE='False'

RUN python manage.py collectstatic --noinput

USER appuser

EXPOSE 8000

ENTRYPOINT ["dumb-init", "--"]
CMD ["scripts/entrypoint.sh"]
