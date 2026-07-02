.DEFAULT_GOAL := help

COMPOSE ?= docker compose
SERVICE ?= backend
MANAGE ?= python manage.py

.PHONY: help build up down restart ps logs clean migrate makemigrations superuser shell test manage lint format setup-pre-commit redis-up celery-up minio-up all-up rebuild

help:
	@echo "Available commands:"
	@echo "  build            - Build Docker images"
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
	@echo "  migrate          - Run Django migrations"
	@echo "  makemigrations   - Create Django migrations"
	@echo "  superuser        - Create a Django superuser"
	@echo "  shell            - Open Django shell"
	@echo "  test             - Run Django tests"
	@echo "  manage           - Run custom command: make manage ARGS='...'"
	@echo "  lint             - Run Ruff linter locally"
	@echo "  format           - Run Ruff formatter locally"
	@echo "  setup-pre-commit - Install pre-commit hooks"

build:
	$(COMPOSE) build

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
	$(COMPOSE) exec $(SERVICE) $(MANAGE) migrate

makemigrations:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) makemigrations

superuser:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) createsuperuser

shell:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) shell

test:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) test

manage:
	$(COMPOSE) exec $(SERVICE) $(MANAGE) $(ARGS)

lint:
	ruff check .

format:
	ruff format .

setup-pre-commit:
	pre-commit install
