# Standardize Makefile for Flask projects
# This Makefile provides common commands for Flask projects, including:
# - install: Install dependencies
# - run: Start the development server
# - test: Run tests
# - lint: Run flake8 to check for code quality issues
# - clean: Remove virtual environment and __pycache__

# ═══════════════════════════════════════════════════════════════
# Makefile — Flask Application
# ═══════════════════════════════════════════════════════════════

.PHONY: help install dev lint fmt test check clean check-all

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
	@echo "$(YELLOW) Running lint and test checks...$(NC)"
	@$(MAKE) lint
	@$(MAKE) test


install: ## Install dependencies into virtualenv
	@echo "Installing dependencies...[1/6]"
	@python3 -m venv venv
	@. venv/bin/activate && pip install --upgrade pip && pip install flask && pip install -r requirements.txt 2>/dev/null || true
	@echo "$(GREEN)✅ Dependencies installed$(NC)"


dev: ## Run Flask development server
	@echo "Starting Flask development server...[2/6]"
	@. venv/bin/activate && FLASK_ENV=development python3 src/main.py

fmt: ## Format code with black
	@echo "Formatting code...[3/6]"
	@. venv/bin/activate && black src/
	@echo "$(GREEN)✅ Formatting complete$(NC)"

lint: ## Lint code with flake8
	@echo "Linting code...[4/6]"
	@. venv/bin/activate && flake8 src/ || (echo "$(RED)🚫 flake8 failed.$(NC)" && exit 1)
	@echo "$(GREEN)✅ Linting complete$(NC)"

test: ## Run tests with pytest
	@echo "Running tests...[5/6]"
	@. venv/bin/activate && if find tests/ -name "test_*.py" -o -name "*_test.py" 2>/dev/null | grep -q .; then \
		pytest tests/ -v || (echo "$(RED)🚫 pytest failed.$(NC)" && exit 1); \
		echo "$(GREEN)✅ Tests passed & Completed.$(NC)"; \
		else \
		echo "$(YELLOW)⚠️  No Python tests found. Skipping.$(NC)"; \
		fi

check: fmt check-all ## Run all checks & optionally can add fmt to run formatting before checks (mirrors pre-push guardrails)
	@echo "$(GREEN)✅ All checks passed — safe to push$(NC)"

clean: ## Remove virtualenv and cache files
	@echo "Cleaning...[6/6]"
	@rm -rf venv/ __pycache__/ .pytest_cache/
	@find . -name "*.pyc" -delete
	@echo "✅ Clean complete"