# AI ERP System - Development Makefile

.PHONY: help dev start stop restart seed logs clean test deploy

help:
	@echo "AI ERP System - Development Commands"
	@echo ""
	@echo "Development:"
	@echo "  make dev           Start development environment"
	@echo "  make dev-api       Start backend API only"
	@echo "  make dev-frontend  Start frontend only"
	@echo ""
	@echo "Deployment:"
	@echo "  make start         Start all services in production"
	@echo "  make stop          Stop all services"
	@echo "  make restart       Restart all services"
	@echo "  make status        Check service status"
	@echo ""
	@echo "Data Management:"
	@echo "  make seed          Populate database with sample data"
	@echo "  make db-migrate    Run database migrations"
	@echo "  make backup        Backup database"
	@echo "  make restore DB_NAME=name  Restore from backup"
	@echo ""
	@echo "Testing:"
	@echo "  make test          Run unit tests"
	@echo "  make test-backend  Run backend tests only"
	@echo "  make test-frontend Run frontend tests only"
	@echo "  make test-e2e      Run end-to-end tests"
	@echo ""
	@echo "Monitoring & Logs:"
	@echo "  make logs          View all logs"
	@echo "  make logs-api      View backend logs"
	@echo "  make logs-app      View application logs"
	@echo "  make clear-logs    Clear log files"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean         Remove unused Docker resources"
	@echo "  make prune         Prune Docker system"
	@echo "  make system-check  Run system health check"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs-start    Start API documentation server"
	@echo "  make swagger-open  Open Swagger UI"
	@echo ""
	@echo "Production:"
	@echo "  make build         Build production images"
	@echo "  make deploy        Deploy to cloud (AWS/GCP)"
	@echo "  make scale N=10    Scale services to N instances"
	@echo ""

dev:
	docker-compose up --build

dev-api:
	docker-compose up backend

dev-frontend:
	cd frontend && npm install && npm run dev

start:
	docker-compose up -d --build

stop:
	docker-compose down

restart:
	docker-compose restart

status:
	docker-compose ps

seed:
	docker-compose exec backend python scripts/seed_data.py

db-migrate:
	docker-compose exec backend alembic upgrade head

backup:
	docker-compose exec db pg_dump -U erp_user erp_db > /tmp/erp_backup_$(shell date +%Y%m%d_%H%M%S).sql

restore:
ifndef DB_NAME
	$(error Usage: make restore DB_NAME=name)
endif
	@echo "Restoring database from backup..."
	@docker-compose exec -T db psql -U erp_user erp_db < /tmp/$(DB_NAME).sql

test:
	docker-compose exec backend pytest tests/unit -v

test-backend:
	docker-compose exec backend pytest tests/unit/backend -v

test-frontend:
	cd frontend && npm test

test-e2e:
	cd tests/e2e && npx playwright test

logs:
	docker-compose logs -f

logs-api:
	docker-compose logs -f backend

logs-app:
	docker-compose logs -f app

clear-logs:
	find . -name "*.log" -type f -delete

clean:
	docker-compose down --remove-orphans
	docker system prune -f

prune:
	docker system prune -a --volumes -f

system-check:
	echo "Checking system health..."
	docker-compose ps
	docker system df

docs-start:
	docker-compose exec backend uvicorn app.main:app --reload --port 8001

swagger-open:
	open http://localhost:8000/docs || xdg-open http://localhost:8000/docs

build:
	docker-compose build --no-cache

deploy:
	@echo "Deploying to cloud infrastructure..."
	@terraform init
	@terraform apply -auto-approve

scale:
ifndef N
	N=3
endif
	docker-compose up --scale backend=$(N)
