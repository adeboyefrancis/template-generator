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

.PHONY: help print-env check-all install dev build lint fmt test check clean \
		# Docker Targets
		docker-install docker-login build-image run-container push-images pull-images docker-exec docker-clean

# Colors for output
YELLOW := \033[0;33m
GREEN  := \033[0;32m
RED    := \033[0;31m
NC     := \033[0m

# Load .env variables if .env.local file exists (Alternatively, you can load .env or other .env.* files as needed)
ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' ./.env)
endif

DOCKER_REPO := ${DOCKER_REPO}
IMAGE_NAME := ${IMAGE_NAME}
CONTAINER_NAME := ${CONTAINER_NAME}
TAG_VERSION := ${TAG_VERSION}
HOST_PORTS := ${HOST_PORTS}
CONTAINER_PORT := ${CONTAINER_PORT}
CURRENT_USER := $(shell whoami)

# Default target
help: ## Show available commands
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


# ═══════════════════════════════════════════════════════════════
# Print Environment Variables (for debugging)
# ═══════════════════════════════════════════════════════════════
print-env: ## Print all environment variables (for debugging)
	@echo "$(YELLOW)Current Environment Variables:$(NC)"
	@env | grep -E '^(DOCKER_REPO|IMAGE_NAME|CONTAINER_NAME|TAG_VERSION|HOST_PORTS|CONTAINER_PORT)=' || echo "No relevant environment variables found."

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



# ═══════════════════════════════════════════════════════════════
# Docker Installation
# ═══════════════════════════════════════════════════════════════
docker-install: ## Docker Installation
	@echo "1. Adding Docker GPG Key..."
	sudo apt update -y
	sudo apt install -y ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	@echo "2. Adding Repository..."
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $$(. /etc/os-release && echo "$${VERSION_CODENAME}") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	@echo "3. Installing Docker Engines..."
	sudo apt update -y
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	@echo "4. Enabling and Starting Services..."
	sudo systemctl enable docker
	sudo systemctl start docker

	@echo "5. Running Post-Installation (User Groups)..."
	sudo groupadd docker || true
	sudo usermod -aG docker $(CURRENT_USER)
	newgrp docker
	@echo "Docker Installation Completed"

# ═══════════════════════════════════════════════════════════════
# Docker Orchestration 
# ═══════════════════════════════════════════════════════════════
docker-login: ## Docker Login
	@echo "Login to Docker Hub via CLI locally"
	@docker login -u ${DOCKER_REPO}

build-image: ## Build Docker image locally
	@echo "Build Docker New docker Image locally...."
	@docker build --build-arg GEMINI_API_KEY=${VITE_GEMINI_API_KEY} -t ${IMAGE_NAME}:${TAG_VERSION} .

run-container: ## Run Image as a Container
	@echo "Running Container using built image...."
	@docker run --name ${CONTAINER_NAME} -p ${HOST_PORTS}:${CONTAINER_PORT} -d ${IMAGE_NAME}:${TAG_VERSION}

push-images: ## Tag & Push Image to Docker Hub
	@echo "Tagging Docker image"
	@docker tag ${IMAGE_NAME}:${TAG_VERSION} ${DOCKER_REPO}/${IMAGE_NAME}:${TAG_VERSION}

	@echo "Pushing Tagged Image to Docker Registry"
	@docker push ${DOCKER_REPO}/${IMAGE_NAME}:${TAG_VERSION}

pull-images: ## Pull Docker Images
	@echo "Pulling docker Image...."
	@docker pull ${DOCKER_REPO}/${IMAGE_NAME}:${TAG_VERSION}


docker-exec: ## Connect to Docker Container via Terminal
	@docker exec -it ${CONTAINER_NAME} /bin/sh

docker-clean: ## Stop Container && Remove Image
# Stop Docker Container
	@echo "Stopping Container...."
	@docker stop ${CONTAINER_NAME}

# Remove Docker Container
	@echo "Removing Container...."
	@docker rm ${CONTAINER_NAME}

# Remove Docker Images
	@echo "Removing Image from Local Host /var/lib/docker/image"
	@docker rmi ${IMAGE_NAME}:${TAG_VERSION}
	@echo "$(GREEN)✅ Docker cleanup complete$(NC)"