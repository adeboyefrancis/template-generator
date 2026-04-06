# Standardize Makefile for React projects
# This Makefile provides common commands for React projects, including:
# - install: Install dependencies
# - start: Start the development server
# - build: Build the project for production
# - test: Run tests
# - lint: Run ESLint to check for code quality issues
# - clean: Remove node_modules and build artifacts

# ═══════════════════════════════════════════════════════════════
# Makefile — React Application
# ═══════════════════════════════════════════════════════════════

.PHONY: help install dev build lint fmt test check clean check-all

# Colors for output
YELLOW := \033[0;33m
GREEN  := \033[0;32m
RED    := \033[0;31m
NC     := \033[0m

PACKAGE_JSON := $(shell [ -f package.json ])

# Default target
help: ## Show available commands
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check-all: ## Run lint and tests with runtime detection
	@echo "$(YELLOW) Running lint and test checks...$(NC)"
	@$(MAKE) lint
	@$(MAKE) test

install: ## Install dependencies
	@echo "Installing dependencies...[1/7]"
	@npm install
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

dev: ## Start React development server
	@echo "Starting React development server...[2/7]"
	@npm start

build: ## Build React app for production
	@echo "Building React app for production...[3/7]"
	@npm run build
	@echo "$(GREEN)✅ Build complete — output in build/$(NC)"

fmt: ## Format code with Prettier
	@echo "Formatting code...[4/7]"
	@npx prettier --write src/
	@echo "$(GREEN)✅ Formatting complete$(NC)"

lint: ## Lint code with ESLint
	@echo "Linting code...[5/7]"
	@npx eslint src/ --quiet || (echo "$(RED)🚫 ESLint failed.$(NC)" && exit 1)
	@echo "$(GREEN)✅ Linting Completed & ESLint passed.$(NC)"

test: ## Run tests with React Testing Library
	@echo "Running tests...[6/7]"
	@if find tests/ -name "*.test.js" -o -name "*.spec.js" 2>/dev/null | grep -q .; then \
		npm test -- --watchAll=false || (echo "$(RED)🚫 Tests failed.$(NC)" && exit 1); \
		echo "$(GREEN)✅ Tests passed & Completed.$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  No JS tests found. Skipping.$(NC)"; \
	fi

check: fmt check-all ## Run all checks & optionally can add fmt to run formatting before checks (mirrors pre-push guardrails)
	@echo "$(GREEN)✅ All checks passed — safe to push$(NC)"

clean: ## Remove build artifacts and dependencies
	@echo "Cleaning...[7/7]"
	@rm -rf node_modules/ build/ .eslintcache
	@echo "✅ Clean complete"