# Standardize Makefile for Spring Boot projects
# This Makefile provides common commands for Spring Boot projects, including:
# - install: Install dependencies
# - run: Start the application
# - test: Run tests
# - lint: Run Checkstyle to check for code quality issues
# - clean: Remove build artifacts

# ═══════════════════════════════════════════════════════════════
# Makefile — Spring Boot Application
# ═══════════════════════════════════════════════════════════════

.PHONY: help install dev build lint test check clean check-all

# Colors for output
YELLOW := \033[0;33m
GREEN  := \033[0;32m
RED    := \033[0;31m
NC     := \033[0m

# Default target
help: ## Show available commands
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check-all: lint test
	@echo "$(YELLOW) Running lint and test checks...$(NC)"
	@$(MAKE) lint
	@$(MAKE) test


install: ## Install Maven dependencies
	@echo "Installing dependencies...[1/6]"
	@./mvnw dependency:resolve
	@echo "$(GREEN)✅ Dependencies installed$(NC)"


dev: ## Run Spring Boot in development mode
	@echo "Starting Spring Boot development server...[2/6]"
	@./mvnw spring-boot:run


build: ## Build the application JAR
	@echo "Building application...[3/6]"
	@./mvnw clean package -DskipTests
	@echo "$(GREEN)✅ Build complete — output in target/$(NC)"

lint: ## Run Checkstyle linter
	@echo "Running Checkstyle...[4/6]"
	@./mvnw checkstyle:check || (echo "$(RED)🚫 Checkstyle failed.$(NC)" && exit 1)
	@echo "$(GREEN)✅ Linting complete$(NC)"

test: ## Run unit tests
	@echo "Running tests...[5/6]"
	@./mvnw test || (echo "$(RED)🚫 Tests failed.$(NC)" && exit 1)
	@echo "$(GREEN)✅ Tests complete$(NC)"

check: check-all ## Run all checks (mirrors pre-push guardrails)
	@echo "$(GREEN)✅ All checks passed — safe to push$(NC)"

clean: ## Remove build artifacts
	@echo "Cleaning..."
	@./mvnw clean
	@echo "✅ Clean complete"