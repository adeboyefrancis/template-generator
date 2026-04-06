#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# bootstrap.sh
# Runs ONCE to scaffold project structure, init git, and set up hooks
# ═══════════════════════════════════════════════════════════════

set -e # Exit immediately if a command exits with a non-zero status

# Colour Schemes
RED='\033[0;31m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# User Profile Variables
current_user=$(whoami)
current_directory=$(pwd)
last_login=$(date)
default_project_path="$HOME/northstar_projects"
branch_name="feature/initial-setup"

echo -e "${BLUE}===================== Project Scaffolder ===============================${NC}"
echo -e "Username:          ${LIGHT_BLUE}$current_user${NC}"
echo -e "Current Directory: ${LIGHT_BLUE}$current_directory${NC}"
echo -e "Shell:             ${GREEN}$SHELL${NC}"
echo -e "Last Login:        ${YELLOW}$last_login${NC}"
echo -e "${BLUE}=======================================================================${NC}"

# ═══════════════════════════════════════════════════════════════
# Functions (Reusable) — Project Guard Rails
# ═══════════════════════════════════════════════════════════════

# Project Name: cannot be empty
check_null_values() {
  while [ -z "$project_name" ]; do
    echo -e "${RED}Project Name cannot be empty.${NC}"
    echo -ne "${LIGHT_BLUE}Please enter your Project Name (e.g. my_app): ${NC}"
    read -r project_name
  done
}

# File Path: project must not already exist
check_file_path() {
  if [ -d "$default_project_path/$project_name" ]; then
    echo -e "${RED}Error: '$project_name' already exists at $default_project_path. Choose a different name.${NC}"
    exit 1
  fi
}

# Scaffold base folders & files — used by all project types
scaffold_base() {
  mkdir -p "$default_project_path/$project_name"/{hooks,src,tests}
  touch "$default_project_path/$project_name"/{.env,.gitignore,README.md}

  # Copy pre-push-checks.sh into project root
  cp "$(dirname "$0")/pre-push-checks.sh" "$default_project_path/$project_name/pre-push-checks.sh"
  chmod +x "$default_project_path/$project_name/pre-push-checks.sh"

  # Copy hooks/pre-push into project hooks/
  cp "$(dirname "$0")/hooks/pre-push" "$default_project_path/$project_name/hooks/pre-push"
  chmod +x "$default_project_path/$project_name/hooks/pre-push"
}

# Write eslint.config.js — ESLint v9+ flat config format
write_eslint_config() {
cat > "$default_project_path/$project_name/eslint.config.js" <<'EOF'
import js from "@eslint/js";

export default [
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module"
    }
  }
];
EOF
}

# Git init + push to GitHub
git_init_and_push() {

  # ✅ Check GitHub authentication FIRST
  if ! gh auth status >/dev/null 2>&1; then
    echo "❌ GitHub CLI not authenticated. Run: gh auth login"
    exit 1
  fi

  cd "$default_project_path/$project_name" || exit
  git init
  git config core.hooksPath hooks
  git switch -c "$branch_name"
  git add .
  git commit -m "Chores(Bootstrap): Initial commit"
  gh repo create "$project_name" --public --source=. #--remote=origin --push  # use --private for private repo
  git push -u origin "$branch_name"
}

# ═══════════════════════════════════════════════════════════════
# Stdin Prompts
# ═══════════════════════════════════════════════════════════════

echo -ne "${LIGHT_BLUE}Please enter your Project Name (e.g. my_app): ${NC}"
read -r project_name
check_null_values
check_file_path

echo -e "\nSelect project type:"
echo -e "${GREEN}1) Node application${NC}"
echo -e "${GREEN}2) Python application${NC}"
echo -e "${GREEN}3) React application${NC}"
echo -e "${GREEN}4) Django application${NC}"
echo -e "${GREEN}5) Flask application${NC}"
echo -e "${GREEN}6) Spring Boot application${NC}"
echo -ne "${LIGHT_BLUE}Please select a project type (1-6): ${NC}"
read -r project_type

# ═══════════════════════════════════════════════════════════════
# SCAFFOLD BY PROJECT TYPE
# ═══════════════════════════════════════════════════════════════
case $project_type in

  1) # ── Node ──────────────────────────────────────────────────
    project_label="Node application"
    scaffold_base
    cp "$(dirname "$0")/templates/node/Makefile" "$default_project_path/$project_name/Makefile"
    write_eslint_config
    echo "// Entry point" > "$default_project_path/$project_name/src/index.js"
    printf "node_modules/\ndist/\n.env\n" > "$default_project_path/$project_name/.gitignore"
    cd "$default_project_path/$project_name" || exit
    npm init -y
    npm pkg set type="module"
    npm install eslint @eslint/js --save-dev
    git_init_and_push
    ;;

  2) # ── Python ────────────────────────────────────────────────
    project_label="Python application"
    scaffold_base
    cp "$(dirname "$0")/templates/python/Makefile" "$default_project_path/$project_name/Makefile"
    echo "# Entry point" > "$default_project_path/$project_name/src/main.py"
    printf "venv/\n__pycache__/\n.env\n*.pyc\n" > "$default_project_path/$project_name/.gitignore"
    cd "$default_project_path/$project_name" || exit
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    pip install --upgrade pip
    git_init_and_push
    ;;

  3) # ── React ─────────────────────────────────────────────────
    project_label="React application"
    scaffold_base
    cp "$(dirname "$0")/templates/react/Makefile" "$default_project_path/$project_name/Makefile"
    write_eslint_config
    mkdir -p "$default_project_path/$project_name/public"
    echo "// Entry point" > "$default_project_path/$project_name/src/index.js"
    printf "node_modules/\nbuild/\n.env\n" > "$default_project_path/$project_name/.gitignore"
    cd "$default_project_path/$project_name" || exit
    npx create-react-app .
    git_init_and_push
    ;;

  4) # ── Django ────────────────────────────────────────────────
    project_label="Django application"
    scaffold_base
    cp "$(dirname "$0")/templates/django/Makefile" "$default_project_path/$project_name/Makefile"
    echo "# Entry point" > "$default_project_path/$project_name/src/main.py"
    printf "venv/\n__pycache__/\n.env\n*.pyc\ndb.sqlite3\n" > "$default_project_path/$project_name/.gitignore"
    cd "$default_project_path/$project_name" || exit
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    pip install --upgrade pip
    pip install django
    django-admin startproject "$project_name" .
    git_init_and_push
    ;;

  5) # ── Flask ─────────────────────────────────────────────────
    project_label="Flask application"
    scaffold_base
    cp "$(dirname "$0")/templates/flask/Makefile" "$default_project_path/$project_name/Makefile"
    echo "# Entry point" > "$default_project_path/$project_name/src/main.py"
    printf "venv/\n__pycache__/\n.env\n*.pyc\n" > "$default_project_path/$project_name/.gitignore"
    cd "$default_project_path/$project_name" || exit
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    pip install --upgrade pip
    pip install flask
    git_init_and_push
    ;;

  6) # ── Spring Boot ───────────────────────────────────────────
    project_label="Spring Boot application"
    scaffold_base
    cp "$(dirname "$0")/templates/springboot/Makefile" "$default_project_path/$project_name/Makefile"
    printf "target/\n.env\n*.class\n" > "$default_project_path/$project_name/.gitignore"
    cd "$default_project_path/$project_name" || exit
    curl https://start.spring.io/starter.zip \
      -d dependencies=web \
      -d name="$project_name" \
      -d type=maven-project \
      -o "$project_name.zip"
    unzip "$project_name.zip" -d .
    rm "$project_name.zip"
    git_init_and_push
    ;;

  *)
    echo -e "${RED}Invalid choice. Please select a valid project type (1-6).${NC}"
    exit 1
    ;;

esac

echo -e "\n${GREEN}✅ '$project_name' ($project_label) created at $default_project_path/$project_name${NC}"
echo -e "${YELLOW}📁 Project structure:${NC}"
#tree -a "$default_project_path/$project_name" # Temporarily removed to avoid dependency on tree command
echo -e "${BLUE}=======================================================================${NC}"
echo -e "${GREEN}🎉 All set! Your project is ready and pushed to GitHub.${NC}"
echo -e "${BLUE}=======================================================================${NC}"

