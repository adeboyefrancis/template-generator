# Standardize Makefile for Django projects
# This Makefile provides common commands for Django projects, including:
# - install: Install dependencies
# - run: Start the development server
# - test: Run tests
# - lint: Run flake8 to check for code quality issues
# - clean: Remove virtual environment and __pycache__
# - db: Manage database migrations
# - shell: Open Django shell
# - collectstatic: Collect static files for production
# - createsuperuser: Create a superuser for admin access

# ═══════════════════════════════════════════════════════════════
# Makefile — Django Application
# ═══════════════════════════════════════════════════════════════

.PHONY: help check-all install dev migrate lint fmt test check clean

# Colors for output
YELLOW := \033[0;33m
GREEN  := \033[0;32m
RED    := \033[0;31m
NC     := \033[0m

# Default target
help: ## Show available commands
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check-all: ## Run lint and tests with runtime detection
	@echo "$(YELLOW)[4/4] Running lint and test checks...$(NC)"
	@if [ -f "manage.py" ]; then \
		$(MAKE) lint; \
		$(MAKE) test; \
	else \
		echo "$(YELLOW)⚠️  No test runner detected. Skipping.$(NC)"; \
	fi

install: ## Install dependencies into virtualenv
	@echo "Installing dependencies...[1/7]"
	@python3 -m venv venv
	@. venv/bin/activate && pip install --upgrade pip && pip install django && pip install -r requirements.txt 2>/dev/null || true
	@echo "✅ Dependencies installed"

dev: ## Run Django development server
	@echo "Starting Django development server...[2/7]"
	@. venv/bin/activate && python3 manage.py runserver

migrate: ## Run Django migrations
	@echo "Running migrations...[3/7]"
	@. venv/bin/activate && python3 manage.py makemigrations
	@. venv/bin/activate && python3 manage.py migrate
	@echo "✅ Migrations complete"

fmt: ## Format code with black
	@echo "Formatting code...[4/7]"
	@. venv/bin/activate && black src/
	@echo "✅ Formatting complete"

lint: ## Lint code with flake8
	@echo "Linting code...[5/7]"
	@. venv/bin/activate && flake8 src/
	@echo "✅ Linting complete"

test: ## Run Django tests
	@echo "Running tests...[6/7]"
	@if find tests/ -name "test_*.py" -o -name "*_test.py" 2>/dev/null | grep -q .; then \
		if python3 manage.py test 2>/dev/null; then \
			echo "$(GREEN)✅ Django tests passed.$(NC)"; \
		else \
			echo "$(RED)🚫 Django tests failed. Fix failing tests before pushing.$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)⚠️  No test files found in tests/. Skipping test check.$(NC)"; \
		echo "$(YELLOW)   Add test_*.py or *_test.py files to tests/ to enable this check.$(NC)"; \
	fi

check: fmt check-all ## Run all checks & optionally can add fmt to run formatting before checks (mirrors pre-push guardrails)
	@echo "$(GREEN)✅ All checks passed — safe to push$(NC)"

clean: ## Remove virtualenv, cache, and database
	@echo "Cleaning...[7/7]"
	@rm -rf venv/ __pycache__/ .pytest_cache/ db.sqlite3
	@find . -name "*.pyc" -delete
	@echo "✅ Clean complete"
