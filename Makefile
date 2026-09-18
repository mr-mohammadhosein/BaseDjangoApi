.DEFAULT_GOAL := help

COMPOSE ?= docker compose
SERVICE ?= backend
MANAGE ?= python manage.py

.PHONY: help build req up down restart ps logs clean migrate migrate-docker makemigrations makemigrations-docker migrations superuser superuser-docker shell shell-docker test test-docker manage manage-docker lint format setup-pre-commit redis-up celery-up minio-up all-up rebuild

help:
	@echo "Available commands:"
	@echo "  build            - Build Docker images"
	@echo "  req              - Install requirements in the local environment"
	@echo "  up               - Start default containers"
	@echo "  redis-up         - Start containers with Redis profile"
	@echo "  celery-up        - Start containers with Celery profile"
	@echo "  minio-up         - Start containers with MinIO profile"
	@echo "  all-up           - Start containers with all profiles"
	@echo "  down             - Stop and remove containers"
	@echo "  restart          - Restart default containers"
	@echo "  ps               - List containers"
	@echo "  logs             - Follow container logs"
	@echo "  clean            - Stop containers and remove orphans"
	@echo "  rebuild          - Rebuild images and restart containers (down + build + up)"
	@echo "  migrate          - Run Django migrations locally"
	@echo "  migrate-docker   - Run Django migrations in the backend container"
	@echo "  makemigrations   - Create Django migrations locally"
	@echo "  makemigrations-docker - Create migrations in the backend container"
	@echo "  superuser        - Create a Django superuser locally"
	@echo "  superuser-docker - Create a superuser in the backend container"
	@echo "  shell            - Open Django shell locally"
	@echo "  shell-docker     - Open Django shell in the backend container"
	@echo "  test             - Run Django tests locally"
	@echo "  test-docker      - Run Django tests in the backend container"
	@echo "  manage           - Run locally: make manage ARGS='...'"
	@echo "  manage-docker    - Run in Docker: make manage-docker ARGS='...'"
	@echo "  lint             - Run Ruff linter locally"
	@echo "  format           - Run Ruff formatter locally"
	@echo "  setup-pre-commit - Install pre-commit hooks"

build:
	$(COMPOSE) build

req:
	pip install -r requirements/local.txt

up:
	$(COMPOSE) up -d

redis-up:
	$(COMPOSE) --profile redis up -d

celery-up:
	$(COMPOSE) --profile celery up -d

minio-up:
	$(COMPOSE) --profile minio up -d

all-up:
	$(COMPOSE) --profile "*" up -d

down:
	$(COMPOSE) down

restart: down up

rebuild: down build up

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --remove-orphans

migrate:
	$(MANAGE) migrate

migrate-docker:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) migrate

makemigrations:
	$(MANAGE) makemigrations

makemigrations-docker:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) makemigrations

# Keep the old plural target as a compatibility alias.
migrations: makemigrations

superuser:
	$(MANAGE) createsuperuser

superuser-docker:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) createsuperuser

shell:
	$(MANAGE) shell

shell-docker:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) shell

test:
	$(MANAGE) test

test-docker:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) test

manage:
	$(MANAGE) $(ARGS)

manage-docker:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) $(ARGS)

lint:
	ruff check .

format:
	ruff format .

setup-pre-commit:
	pre-commit install
