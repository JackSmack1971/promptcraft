#!/bin/bash

# PromptCraft Development Environment Setup for Codex
# This script prepares the sandbox environment for AI-powered prompt engineering platform development

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    log_error "This script should not be run as root"
    exit 1
fi

log_info "Starting PromptCraft development environment setup..."

# Update system packages
log_info "Updating system packages..."
sudo apt-get update -qq

# Install essential system dependencies
log_info "Installing system dependencies..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    unzip \
    htop \
    tree \
    nano

# Install Node.js 20.x (LTS)
log_info "Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node.js installation
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
log_success "Node.js ${NODE_VERSION} and npm ${NPM_VERSION} installed"

# Install Yarn package manager
log_info "Installing Yarn package manager..."
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -qq
sudo apt-get install -y yarn

# Install pnpm (alternative package manager for performance)
log_info "Installing pnpm..."
npm install -g pnpm@latest

# Install Docker
log_info "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

# Install Docker Compose
log_info "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install PostgreSQL client tools
log_info "Installing PostgreSQL client..."
sudo apt-get install -y postgresql-client-15

# Install Redis client tools
log_info "Installing Redis client..."
sudo apt-get install -y redis-tools

# Install Python 3 and pip (for some development tools)
log_info "Installing Python 3 and pip..."
sudo apt-get install -y python3 python3-pip

# Install global npm packages for development
log_info "Installing global npm packages..."
npm install -g \
    typescript@latest \
    @types/node@latest \
    eslint@latest \
    prettier@latest \
    nodemon@latest \
    ts-node@latest \
    prisma@latest \
    @prisma/client@latest \
    concurrently@latest

# Install testing tools
log_info "Installing testing tools..."
npm install -g \
    jest@latest \
    @testing-library/jest-dom@latest \
    playwright@latest

# Initialize Playwright browsers
log_info "Setting up Playwright browsers..."
npx playwright install --with-deps

# Install database migration and seeding tools
log_info "Installing database tools..."
npm install -g \
    knex@latest \
    db-migrate@latest \
    db-migrate-pg@latest

# Install AI/ML development tools
log_info "Installing AI development dependencies..."
pip3 install --user \
    tiktoken \
    openai \
    anthropic \
    google-generativeai

# Install development utilities
log_info "Installing development utilities..."
npm install -g \
    http-server@latest \
    live-server@latest \
    json-server@latest \
    newman@latest \
    artillery@latest

# Setup environment for PromptCraft specific needs
log_info "Setting up PromptCraft-specific environment..."

# Create project directory structure
mkdir -p ~/promptcraft/{frontend,backend,database,docs,scripts}

# Setup Git configuration for Codex
log_info "Configuring Git for Codex environment..."
git config --global user.name "Codex Agent"
git config --global user.email "codex@promptcraft.dev"
git config --global init.defaultBranch main
git config --global pull.rebase false

# Create useful aliases and functions
log_info "Setting up development aliases..."
cat >> ~/.bashrc << 'EOF'

# PromptCraft Development Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Docker aliases
alias dc='docker-compose'
alias dps='docker ps'
alias dlog='docker-compose logs -f'

# Node.js aliases
alias nr='npm run'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nt='npm test'
alias nb='npm run build'
alias nd='npm run dev'

# Database aliases
alias pgcli='psql postgresql://postgres:password@localhost:5432/promptcraft'
alias redis-cli='redis-cli -h localhost -p 6379'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gb='git branch'
alias gco='git checkout'

# PromptCraft specific functions
pcdev() {
    echo "Starting PromptCraft development environment..."
    cd ~/promptcraft && docker-compose up -d
}

pcstop() {
    echo "Stopping PromptCraft development environment..."
    cd ~/promptcraft && docker-compose down
}

pclogs() {
    cd ~/promptcraft && docker-compose logs -f "$@"
}

pctest() {
    echo "Running PromptCraft test suite..."
    cd ~/promptcraft && npm run test
}

pcbuild() {
    echo "Building PromptCraft for production..."
    cd ~/promptcraft && npm run build
}

pcreset() {
    echo "Resetting PromptCraft database..."
    cd ~/promptcraft && npm run db:reset
}
EOF

# Create environment template file
log_info "Creating environment template..."
cat > ~/promptcraft/.env.example << 'EOF'
# Database Configuration
DATABASE_URL=postgresql://postgres:password@localhost:5432/promptcraft
REDIS_URL=redis://localhost:6379

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-token-secret
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d

# AI Provider API Keys
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
GOOGLE_AI_API_KEY=your-google-ai-api-key

# Application Configuration
NODE_ENV=development
PORT=8000
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:8000

# Email Configuration (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=1000

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_DIR=./uploads

# Monitoring and Analytics
SENTRY_DSN=your-sentry-dsn
ANALYTICS_KEY=your-analytics-key

# Development specific
LOG_LEVEL=debug
ENABLE_CORS=true
CORS_ORIGIN=http://localhost:3000
EOF

# Create a basic package.json for the project root
log_info "Creating project package.json..."
cat > ~/promptcraft/package.json << 'EOF'
{
  "name": "promptcraft",
  "version": "1.0.0",
  "description": "AI-powered prompt engineering platform for novice users",
  "main": "index.js",
  "scripts": {
    "dev": "concurrently \"npm run dev:backend\" \"npm run dev:frontend\"",
    "dev:backend": "cd backend && npm run dev",
    "dev:frontend": "cd frontend && npm run dev",
    "build": "npm run build:backend && npm run build:frontend",
    "build:backend": "cd backend && npm run build",
    "build:frontend": "cd frontend && npm run build",
    "test": "npm run test:backend && npm run test:frontend",
    "test:backend": "cd backend && npm test",
    "test:frontend": "cd frontend && npm test",
    "lint": "npm run lint:backend && npm run lint:frontend",
    "lint:backend": "cd backend && npm run lint",
    "lint:frontend": "cd frontend && npm run lint",
    "migrate:up": "cd backend && npm run migrate:up",
    "migrate:down": "cd backend && npm run migrate:down",
    "seed": "cd backend && npm run seed",
    "db:reset": "cd backend && npm run db:reset",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "docker:logs": "docker-compose logs -f"
  },
  "keywords": [
    "ai",
    "prompt-engineering",
    "openai",
    "anthropic",
    "google-ai",
    "template-management",
    "react",
    "nodejs",
    "typescript"
  ],
  "author": "PromptCraft Team",
  "license": "MIT",
  "devDependencies": {
    "concurrently": "^8.2.2"
  }
}
EOF

# Create basic docker-compose.yml for development
log_info "Creating Docker Compose configuration..."
cat > ~/promptcraft/docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: promptcraft
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8025"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
  redis_data:

networks:
  default:
    name: promptcraft-network
EOF

# Create helpful development scripts
log_info "Creating development helper scripts..."
mkdir -p ~/promptcraft/scripts

cat > ~/promptcraft/scripts/setup-dev.sh << 'EOF'
#!/bin/bash
# Development environment setup script

set -e

echo "Setting up PromptCraft development environment..."

# Start services
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Install dependencies
echo "Installing backend dependencies..."
cd backend && npm install

echo "Installing frontend dependencies..."
cd ../frontend && npm install

# Run migrations
echo "Running database migrations..."
cd ../backend && npm run migrate:up

# Seed development data
echo "Seeding development data..."
npm run seed

echo "Development environment ready!"
echo "Access the application at: http://localhost:3000"
echo "Backend API at: http://localhost:8000"
echo "MailHog at: http://localhost:8025"
EOF

chmod +x ~/promptcraft/scripts/setup-dev.sh

# Create database initialization script
mkdir -p ~/promptcraft/database/init
cat > ~/promptcraft/database/init/01-init.sql << 'EOF'
-- PromptCraft database initialization
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create development user
DO
$do$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'promptcraft_dev') THEN
      CREATE ROLE promptcraft_dev LOGIN PASSWORD 'dev_password';
   END IF;
END
$do$;

GRANT ALL PRIVILEGES ON DATABASE promptcraft TO promptcraft_dev;
EOF

# Set up environment variables for current session
log_info "Setting up environment variables..."
echo "export PATH=\$PATH:/usr/local/bin" >> ~/.bashrc

# Install additional tools for AI development
log_info "Installing additional AI development tools..."

# Install curl for API testing
sudo apt-get install -y curl

# Install jq for JSON processing
sudo apt-get install -y jq

# Install httpie for API testing
pip3 install --user httpie

# Install tiktoken for token counting (Python)
pip3 install --user tiktoken

# Source the bashrc to apply aliases
source ~/.bashrc || true

# Final setup tasks
log_info "Performing final setup tasks..."

# Create logs directory
mkdir -p ~/promptcraft/logs

# Create uploads directory
mkdir -p ~/promptcraft/uploads

# Set proper permissions
chmod 755 ~/promptcraft/scripts/*.sh

# Verify installations
log_info "Verifying installations..."

# Check Node.js
node --version
npm --version

# Check Docker
docker --version
docker-compose --version

# Check PostgreSQL client
psql --version

# Check Redis client
redis-cli --version

# Display final information
log_success "PromptCraft development environment setup completed!"
echo ""
echo "🚀 Environment Details:"
echo "   Node.js: $(node --version)"
echo "   npm: $(npm --version)"
echo "   Docker: $(docker --version | cut -d',' -f1)"
echo "   Docker Compose: $(docker-compose --version | cut -d',' -f1)"
echo ""
echo "📁 Project Structure:"
echo "   ~/promptcraft/ - Main project directory"
echo "   ~/promptcraft/frontend/ - React frontend"
echo "   ~/promptcraft/backend/ - Node.js backend"
echo "   ~/promptcraft/database/ - Database scripts"
echo ""
echo "🔧 Quick Commands:"
echo "   pcdev     - Start development environment"
echo "   pcstop    - Stop development environment"
echo "   pclogs    - View application logs"
echo "   pctest    - Run test suite"
echo "   pcreset   - Reset database"
echo ""
echo "🌐 Development URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   MailHog: http://localhost:8025"
echo "   PostgreSQL: localhost:5432"
echo "   Redis: localhost:6379"
echo ""
echo "📚 Next Steps:"
echo "   1. Copy .env.example to .env and configure API keys"
echo "   2. Run 'pcdev' to start the development environment"
echo "   3. Navigate to ~/promptcraft to begin development"
echo ""
log_warning "Remember to restart your terminal or run 'source ~/.bashrc' to load new aliases!"
