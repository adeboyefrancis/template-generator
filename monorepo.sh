#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════
# monorepo.sh
# Runs ONCE to scaffold project structure, init git, and set up hooks
# Usage:1) -> Run monorepo from anywhere, creates project in default location: /northstar_projects/my_app
#       2) -> Run with project name and custom path: monorepo my_app /custom/path, creates /custom/path/my_app
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# GLOBAL PATH
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"

# ═══════════════════════════════════════════════════════════════
# COLOURS
# ═══════════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
# USER / CONFIG
# ═══════════════════════════════════════════════════════════════

current_user=$(whoami)
current_directory=$(pwd)
last_login=$(date)

default_project_path="${PROJECTS_HOME:-$HOME/northstar_projects}"

branch_name="feature/initial-setup"

# Use Husky only when Node ecosystem exists
use_husky=false

# ═══════════════════════════════════════════════════════════════
# BANNER
# ═══════════════════════════════════════════════════════════════

echo -e "${BLUE}===================== Monorepo Scaffolder ==============================${NC}"
echo -e "Username:          ${LIGHT_BLUE}$current_user${NC}"
echo -e "Current Directory: ${LIGHT_BLUE}$current_directory${NC}"
echo -e "Shell:             ${GREEN}$SHELL${NC}"
echo -e "Last Login:        ${YELLOW}$last_login${NC}"
echo -e "${BLUE}=======================================================================${NC}"

# ═══════════════════════════════════════════════════════════════
# HELPERS
# ═══════════════════════════════════════════════════════════════

log_success() { echo -e "${GREEN}  ✔ $1${NC}"; }
log_warning() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
log_error()   { echo -e "${RED}  ✖ $1${NC}"; }

safe_copy() {
  local src="$1"
  local dest="$2"

  if [ -f "$src" ]; then
    cp "$src" "$dest"
  else
    log_warning "Missing template: $src"
  fi
}

# ═══════════════════════════════════════════════════════════════
# INPUT HANDLING
# ═══════════════════════════════════════════════════════════════

if [ -n "${1:-}" ]; then
  project_name="$1"
else
  echo -ne "${LIGHT_BLUE}Please enter your Project Name (e.g. my_app): ${NC}"
  read -r project_name
fi

while [ -z "$project_name" ]; do
  log_error "Project name cannot be empty."
  read -r project_name
done

target_path="${2:-$default_project_path}"

mkdir -p "$target_path"

project_dir="$target_path/$project_name"

if [ -d "$project_dir" ]; then
  log_error "'$project_name' already exists at $target_path"
  exit 1
fi

# ═══════════════════════════════════════════════════════════════
# SECTION CONFIGURATION
# ═══════════════════════════════════════════════════════════════

echo -e "\n${CYAN}Configure API ${NC}"

echo "1) Go"
echo "2) Python"
echo "3) Node.js"
echo "4) Spring Boot"
echo "5) Skip"

echo -ne "${LIGHT_BLUE}Your choices (e.g. 1 2): ${NC}"

read -r -a api_choices

echo -e "\n${CYAN}Configure WEB ${NC}"

echo "1) App"
echo "2) Dashboard"
echo "3) Supabase"
echo "4) Skip"

echo -ne "${LIGHT_BLUE}Your choices (e.g. 1 2): ${NC}"

read -r -a web_choices

echo -e "\n${CYAN}Configure APP ${NC}"

echo "1) Android"
echo "2) iOS"
echo "3) Flutter"
echo "4) Skip"

echo -ne "${LIGHT_BLUE}Your choices (e.g. 1 2): ${NC}"

read -r -a app_choices

echo -e "\n${CYAN}Configure DEPLOY ${NC}"

echo "1) Docker"
echo "2) Helm"
echo "3) Terraform"
echo "4) Skip"

echo -ne "${LIGHT_BLUE}Your choices (e.g. 1 2): ${NC}"

read -r -a deploy_choices

# ═══════════════════════════════════════════════════════════════
# DETECT NODE ECOSYSTEM
# ═══════════════════════════════════════════════════════════════

for choice in "${api_choices[@]}"; do
  if [ "$choice" = "3" ]; then
    use_husky=true
  fi
done

for choice in "${web_choices[@]}"; do
  if [ "$choice" = "1" ] || [ "$choice" = "2" ]; then
    use_husky=true
  fi
done

# ═══════════════════════════════════════════════════════════════
# ROOT STRUCTURE
# ═══════════════════════════════════════════════════════════════

scaffold_root() {

  mkdir -p "$project_dir"/{docs,scripts}

  if [ "$use_husky" = false ]; then
    mkdir -p "$project_dir/hooks"
  fi

  touch "$project_dir"/{README.md,CHANGELOG.md,CONTRIBUTING.md,LICENSE,CODEOWNERS,.gitignore,.dockerignore,.editorconfig}

  touch "$project_dir/Makefile"

  safe_copy \
    "$SCRIPT_DIR/pre-push-checks.sh" \
    "$project_dir/scripts/pre-push-checks.sh"

  chmod +x "$project_dir/scripts/pre-push-checks.sh"

  if [ "$use_husky" = false ]; then

    safe_copy \
      "$SCRIPT_DIR/hooks/pre-push" \
      "$project_dir/hooks/pre-push"

    chmod +x "$project_dir/hooks/pre-push"
  fi

  log_success "Root structure created"
}

# ═══════════════════════════════════════════════════════════════
# API GENERATORS
# ═══════════════════════════════════════════════════════════════

scaffold_api() {

  echo -e "\n${CYAN}── api/ ────────────────────────────────────────────────${NC}"

  for choice in "${api_choices[@]}"; do

    case $choice in

      1)
        mkdir -p "$project_dir/api"/{cmd,internal,pkg}

        touch "$project_dir/api/main.go"
        touch "$project_dir/api/go.mod"

        safe_copy \
          "$SCRIPT_DIR/templates/go/Makefile" \
          "$project_dir/api/Makefile"

        log_success "Go API configured"
        ;;

      2)
        mkdir -p "$project_dir/api"/{src,tests}

        touch "$project_dir/api/src/main.py"
        touch "$project_dir/api/requirements.txt"

        log_success "Python API configured"
        ;;

      3)
        mkdir -p "$project_dir/api"/{src,routes,middleware}

        touch "$project_dir/api/src/index.js"
        touch "$project_dir/api/package.json"

        safe_copy \
          "$SCRIPT_DIR/templates/node/eslint.config.js" \
          "$project_dir/api/eslint.config.js"

        log_success "Node.js API configured"
        ;;

      4)
        mkdir -p "$project_dir/api/springboot"

        cd "$project_dir/api/springboot" || exit

        curl -fsSL https://start.spring.io/starter.zip \
          -d dependencies=web \
          -d name="$project_name-api" \
          -d type=maven-project \
          -o starter.zip

        unzip -q starter.zip

        rm starter.zip

        cd "$project_dir" || exit

        log_success "Spring Boot API configured"
        ;;

      5)
        log_warning "API section skipped"
        ;;

      *)
        log_error "Unknown API choice: $choice"
        ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
# WEB GENERATORS
# ═══════════════════════════════════════════════════════════════

scaffold_web() {

  echo -e "\n${CYAN}── web/ ────────────────────────────────────────────────${NC}"

  for choice in "${web_choices[@]}"; do

    case $choice in

      1)
        mkdir -p "$project_dir/web/app"/{public,src}

        touch "$project_dir/web/app/index.html"
        touch "$project_dir/web/app/src/main.jsx"
        touch "$project_dir/web/app/src/App.jsx"

        safe_copy \
          "$SCRIPT_DIR/templates/react/eslint.config.js" \
          "$project_dir/web/app/eslint.config.js"

        log_success "web/app configured"
        ;;

      2)
        mkdir -p "$project_dir/web/dashboard"/{public,src}

        touch "$project_dir/web/dashboard/index.html"
        touch "$project_dir/web/dashboard/src/main.jsx"
        touch "$project_dir/web/dashboard/src/App.jsx"

        safe_copy \
          "$SCRIPT_DIR/templates/react/eslint.config.js" \
          "$project_dir/web/dashboard/eslint.config.js"

        log_success "web/dashboard configured"
        ;;

      3)
        mkdir -p "$project_dir/web/supabase"/{migrations,functions}

        touch "$project_dir/web/supabase/config.toml"

        log_success "web/supabase configured"
        ;;

      4)
        log_warning "Web section skipped"
        ;;

      *)
        log_error "Unknown WEB choice: $choice"
        ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
# APP GENERATORS
# ═══════════════════════════════════════════════════════════════

scaffold_app() {

  echo -e "\n${CYAN}── app/ ────────────────────────────────────────────────${NC}"

  for choice in "${app_choices[@]}"; do

    case $choice in

      1)
        mkdir -p "$project_dir/app/android"/{app/src/main,gradle}

        touch "$project_dir/app/android/build.gradle"

        log_success "Android app configured"
        ;;

      2)
        mkdir -p "$project_dir/app/ios"/{Sources,Resources}

        touch "$project_dir/app/ios/Podfile"

        log_success "iOS app configured"
        ;;

      3)
        mkdir -p "$project_dir/app/flutter"/{lib,test,assets}

        touch "$project_dir/app/flutter/pubspec.yaml"

        log_success "Flutter app configured"
        ;;

      4)
        log_warning "App section skipped"
        ;;

      *)
        log_error "Unknown APP choice: $choice"
        ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
# DEPLOY GENERATORS
# ═══════════════════════════════════════════════════════════════

scaffold_deploy() {

  echo -e "\n${CYAN}── deploy/ ─────────────────────────────────────────────${NC}"

  for choice in "${deploy_choices[@]}"; do

    case $choice in

      1)
        mkdir -p "$project_dir/deploy/docker"

        safe_copy \
          "$SCRIPT_DIR/templates/Dockerfile" \
          "$project_dir/deploy/docker/Dockerfile"

        safe_copy \
          "$SCRIPT_DIR/templates/docker-compose.yml" \
          "$project_dir/deploy/docker/docker-compose.yml"

        safe_copy \
          "$SCRIPT_DIR/templates/.dockerignore" \
          "$project_dir/deploy/docker/.dockerignore"

        log_success "Docker configured"
        ;;

      2)
        mkdir -p "$project_dir/deploy/helm"/{templates,charts}

        touch "$project_dir/deploy/helm/Chart.yaml"
        touch "$project_dir/deploy/helm/values.yaml"

        log_success "Helm configured"
        ;;

      3)
        mkdir -p "$project_dir/deploy/terraform"/{modules,environments}

        touch "$project_dir/deploy/terraform/main.tf"
        touch "$project_dir/deploy/terraform/variables.tf"
        touch "$project_dir/deploy/terraform/outputs.tf"

        log_success "Terraform configured"
        ;;

      4)
        log_warning "Deploy section skipped"
        ;;

      *)
        log_error "Unknown DEPLOY choice: $choice"
        ;;
    esac
  done
}

# ═══════════════════════════════════════════════════════════════
# DOCS
# ═══════════════════════════════════════════════════════════════

scaffold_docs() {

  echo -e "\n${CYAN}── docs/ ───────────────────────────────────────────────${NC}"

  mkdir -p "$project_dir/docs"/{architecture,api,guides}

  touch "$project_dir/docs/architecture/.gitkeep"
  touch "$project_dir/docs/api/.gitkeep"
  touch "$project_dir/docs/guides/.gitkeep"

  log_success "docs configured"
}

# ═══════════════════════════════════════════════════════════════
# HUSKY SETUP
# ═══════════════════════════════════════════════════════════════

setup_husky() {

  echo -e "\n${BLUE}Setting up Husky...${NC}"

  cd "$project_dir" || exit

  npm init -y

  npm install --save-dev husky

  npx husky init

  chmod +x .husky/pre-commit

  log_success "Husky configured"
}

# ═══════════════════════════════════════════════════════════════
# GIT + GITHUB
# ═══════════════════════════════════════════════════════════════

git_init_and_push() {

  if ! gh auth status >/dev/null 2>&1; then
    log_error "GitHub CLI not authenticated"
    echo -e "${YELLOW}Run:${NC} gh auth login"
    exit 1
  fi

  gh_user=$(gh api user --jq .login)

  gh_protocol=$(gh config get git_protocol 2>/dev/null || echo "https")

  GH_TOKEN=$(gh auth token)

  export GH_TOKEN

  cd "$project_dir" || exit

  git init

  if [ "$use_husky" = false ]; then
    git config --local core.hooksPath hooks
  fi

  git switch -c "$branch_name"

  git add .

  git commit -m "Monorepo(Bootstrap): Initial setup commit"

  gh repo create "$project_name" --public --source=.

  if ! git remote | grep -q "origin"; then

    if [ "$gh_protocol" = "ssh" ]; then
      git remote add origin "git@github.com:$gh_user/$project_name.git"
    else
      git remote add origin "https://github.com/$gh_user/$project_name.git"
    fi
  fi

  git push -u origin "$branch_name"

  git fetch origin

  git switch -c main

  git push -u origin main --no-verify

  git switch "$branch_name"
}

# ═══════════════════════════════════════════════════════════════
# RUN
# ═══════════════════════════════════════════════════════════════

echo -e "\n${BLUE}Scaffolding monorepo structure...${NC}"

scaffold_root
scaffold_api
scaffold_web
scaffold_app
scaffold_deploy
scaffold_docs

if [ "$use_husky" = true ]; then
  setup_husky
fi

echo -e "\n${BLUE}Initializing Git repository...${NC}"

git_init_and_push

# ═══════════════════════════════════════════════════════════════
# FINAL OUTPUT
# ═══════════════════════════════════════════════════════════════

echo -e "\n${GREEN}✅ '$project_name' monorepo created successfully.${NC}"

echo -e "${LIGHT_BLUE}$project_dir${NC}"

echo -e "${BLUE}=======================================================================${NC}"

echo -e "${GREEN}🎉 All set! '$project_name' is scaffolded and pushed to GitHub.${NC}"

echo -e "${BLUE}=======================================================================${NC}"