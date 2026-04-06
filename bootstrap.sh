#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════
# bootstrap.sh
# Runs ONCE to scaffold project structure, init git, and set up hooks
# Usage:1) -> Run bootstrap from anywhere, creates project in default location: /northstar_projects/my_app
#       2) -> Run with project name and custom path: bootstrap my_app /custom/path, creates /custom/path/my_app
# ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════

set -e # Exit immediately if a command exits with a non-zero status
 
# ═══════════════════════════════════════════════════════════════
# GLOBAL PATH
# ═══════════════════════════════════════════════════════════════
SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
 
# ═══════════════════════════════════════════════════════════════
# Colours
# ═══════════════════════════════════════════════════════════════
RED='\033[0;31m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
 
# ═══════════════════════════════════════════════════════════════
# User / Config
# ═══════════════════════════════════════════════════════════════
current_user=$(whoami)
current_directory=$(pwd)
last_login=$(date)
 
# Configurable default path (supports env override)
default_project_path="${PROJECTS_HOME:-$HOME/northstar_projects}"
branch_name="feature/initial-setup"
 
echo -e "${BLUE}===================== Project Scaffolder ===============================${NC}"
echo -e "Username:          ${LIGHT_BLUE}$current_user${NC}"
echo -e "Current Directory: ${LIGHT_BLUE}$current_directory${NC}"
echo -e "Shell:             ${GREEN}$SHELL${NC}"
echo -e "Last Login:        ${YELLOW}$last_login${NC}"
echo -e "${BLUE}=======================================================================${NC}"
 
# ═══════════════════════════════════════════════════════════════
# INPUT HANDLING (CLI ARG + PROMPT HYBRID)
# ═══════════════════════════════════════════════════════════════
 
if [ -n "$1" ]; then
  project_name="$1"
else
  echo -ne "${LIGHT_BLUE}Please enter your Project Name (e.g. my_app): ${NC}"
  read -r project_name
fi
 
# Guard: project name cannot be empty
check_null_values() {
  while [ -z "$project_name" ]; do
    echo -e "${RED}Project Name cannot be empty.${NC}"
    read -r project_name
  done
}
check_null_values
 
# Determine target path
target_path="${2:-$default_project_path}"
mkdir -p "$target_path"
 
# Final project directory
project_dir="$target_path/$project_name"
 
# Guard: project must not already exist
check_file_path() {
  if [ -d "$project_dir" ]; then
    echo -e "${RED}Error: '$project_name' already exists at $target_path.${NC}"
    exit 1
  fi
}
check_file_path
 
# ═══════════════════════════════════════════════════════════════
# CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════
 
scaffold_base() {
  mkdir -p "$project_dir"/{hooks,src,tests}
  touch "$project_dir"/{.env,.gitignore,README.md}
 
  cp "$SCRIPT_DIR/pre-push-checks.sh" "$project_dir/pre-push-checks.sh"
  chmod +x "$project_dir/pre-push-checks.sh"
 
  cp "$SCRIPT_DIR/hooks/pre-push" "$project_dir/hooks/pre-push"
  chmod +x "$project_dir/hooks/pre-push"
}
 
write_eslint_config() {
cat > "$project_dir/eslint.config.js" <<'EOF'
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
 
git_init_and_push() {
  # GitHub auth check
  if ! gh auth status >/dev/null 2>&1; then
    echo -e "${RED}❌ GitHub CLI not authenticated. Run: gh auth login${NC}"
    exit 1
  fi
 
  # Export token for non-interactive shell
  GH_TOKEN=$(gh auth token)
  export GH_TOKEN
 
  cd "$project_dir" || exit
  git init
  git config core.hooksPath hooks
  git switch -c "$branch_name"
  git add .
  git commit -m "Chores(Bootstrap): Initial commit"
  gh repo create "$project_name" --public --source=. #--remote=origin --push  # use --private for private repo
  git push -u origin "$branch_name"
}
 
# ═══════════════════════════════════════════════════════════════
# PROJECT TYPE SELECTION
# ═══════════════════════════════════════════════════════════════
 
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
# SCAFFOLD LOGIC
# ═══════════════════════════════════════════════════════════════
 
case $project_type in
 
  1)
    project_label="Node application"
    scaffold_base
    cp "$SCRIPT_DIR/templates/node/Makefile" "$project_dir/Makefile"
    write_eslint_config
    echo "// Entry point" > "$project_dir/src/index.js"
    printf "node_modules/\ndist/\n.env\n" > "$project_dir/.gitignore"
    cd "$project_dir" || exit
    npm init -y
    npm pkg set type="module"
    npm install eslint @eslint/js --save-dev
    git_init_and_push
    ;;
 
  2)
    project_label="Python application"
    scaffold_base
    cp "$SCRIPT_DIR/templates/python/Makefile" "$project_dir/Makefile"
    echo "# Entry point" > "$project_dir/src/main.py"
    printf "venv/\n__pycache__/\n.env\n*.pyc\n" > "$project_dir/.gitignore"
    cd "$project_dir" || exit
    python3 -m venv venv
    # shellcheck source=/dev/null
    source venv/bin/activate
    pip install --upgrade pip
    git_init_and_push
    ;;
 
  3)
    project_label="React application"
    scaffold_base
    cp "$SCRIPT_DIR/templates/react/Makefile" "$project_dir/Makefile"
    write_eslint_config
    mkdir -p "$project_dir/public"
    echo "// Entry point" > "$project_dir/src/index.js"
    printf "node_modules/\nbuild/\n.env\n" > "$project_dir/.gitignore"
    cd "$project_dir" || exit
    npx create-react-app .
    git_init_and_push
    ;;
 
  4)
    project_label="Django application"
    scaffold_base
    cp "$SCRIPT_DIR/templates/django/Makefile" "$project_dir/Makefile"
    echo "# Entry point" > "$project_dir/src/main.py"
    printf "venv/\n__pycache__/\n.env\n*.pyc\ndb.sqlite3\n" > "$project_dir/.gitignore"
    cd "$project_dir" || exit
    python3 -m venv venv
    # shellcheck source=/dev/null
    source venv/bin/activate
    pip install --upgrade pip
    pip install django
    django-admin startproject "$project_name" .
    git_init_and_push
    ;;
 
  5)
    project_label="Flask application"
    scaffold_base
    cp "$SCRIPT_DIR/templates/flask/Makefile" "$project_dir/Makefile"
    echo "# Entry point" > "$project_dir/src/main.py"
    printf "venv/\n__pycache__/\n.env\n*.pyc\n" > "$project_dir/.gitignore"
    cd "$project_dir" || exit
    python3 -m venv venv
    # shellcheck source=/dev/null
    source venv/bin/activate
    pip install --upgrade pip
    pip install flask
    git_init_and_push
    ;;
 
  6)
    project_label="Spring Boot application"
    scaffold_base
    cp "$SCRIPT_DIR/templates/springboot/Makefile" "$project_dir/Makefile"
    printf "target/\n.env\n*.class\n" > "$project_dir/.gitignore"
    cd "$project_dir" || exit
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
    echo -e "${RED}Invalid choice.${NC}"
    exit 1
    ;;
esac
 
# ═══════════════════════════════════════════════════════════════
# FINAL OUTPUT
# ═══════════════════════════════════════════════════════════════
 
echo -e "\n${GREEN}✅ '$project_name' ($project_label) created at $project_dir${NC}"
echo -e "${BLUE}=======================================================================${NC}"
echo -e "${GREEN}🎉 All set! Your project is ready and pushed to GitHub.${NC}"
echo -e "${BLUE}=======================================================================${NC}"