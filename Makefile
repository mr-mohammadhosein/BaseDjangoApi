.DEFAULT_GOAL := help

COMPOSE ?= docker compose
SERVICE ?= backend

.PHONY: help build up down restart ps logs migrate makemigrations superuser shell test lint format setup-pre-commit redis-up celery-up minio-up all-up clean

help:
	@echo "Available commands:"
	@echo "  build            - Build docker images"
	@echo "  up               - Start docker containers"
	@echo "  down             - Stop docker containers"
	@echo "  restart          - Restart docker containers"
	@echo "  ps               - List docker containers"
	@echo "  logs             - View docker logs"
	@echo "  migrate          - Run django migrations"
	@echo "  makemigrations   - Create django migrations"
	@echo "  superuser        - Create django superuser"
	@echo "  shell            - Open django shell"
	@echo "  test             - Run tests"
	@echo "  lint             - Run ruff linter"
	@echo "  format           - Run ruff formatter"
	@echo "  setup-pre-commit - Install pre-commit hooks"
	@echo "  redis-up         - Start containers with redis"
	@echo "  celery-up        - Start containers with celery"
	@echo "  minio-up         - Start containers with minio"
	@echo "  all-up           - Start containers with all services"

# Docker lifecycle
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

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down --remove-orphans

# Django commands
migrate:
	$(COMPOSE) exec $(SERVICE) python manage.py migrate

makemigrations:
	$(COMPOSE) exec $(SERVICE) python manage.py makemigrations

superuser:
	$(COMPOSE) exec $(SERVICE) python manage.py createsuperuser

shell:
	$(COMPOSE) exec $(SERVICE) python manage.py shell

test:
	$(COMPOSE) exec $(SERVICE) python manage.py test

# Local quality tools
lint:
	ruff check .

format:
	ruff format .

setup-pre-commit:
	pre-commit install
