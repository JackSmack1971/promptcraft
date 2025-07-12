#!/bin/bash

# PromptCraft Codex Setup Script
# This script runs at the start of every Codex task after repo cloning
# Network access is enabled during this phase

set -euo pipefail

echo "🚀 Setting up PromptCraft development environment for Codex..."

# Install Node.js 20.x if not present
if ! command -v node &> /dev/null || [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 20 ]]; then
    echo "📦 Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install pnpm for fast package management
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    npm install -g pnpm@latest
fi

# Install essential global tools
echo "🔧 Installing global development tools..."
npm install -g \
    typescript@latest \
    ts-node@latest \
    prisma@latest \
    nodemon@latest \
    concurrently@latest

# Install Python dependencies for AI tools
echo "🤖 Installing AI development dependencies..."
pip3 install --user \
    tiktoken \
    openai \
    anthropic \
    google-generativeai

# Install backend dependencies
if [ -f "backend/package.json" ]; then
    echo "📥 Installing backend dependencies..."
    cd backend
    pnpm install --frozen-lockfile
    cd ..
fi

# Install frontend dependencies  
if [ -f "frontend/package.json" ]; then
    echo "📥 Installing frontend dependencies..."
    cd frontend
    pnpm install --frozen-lockfile
    cd ..
fi

# Install root dependencies if present
if [ -f "package.json" ]; then
    echo "📥 Installing root dependencies..."
    pnpm install --frozen-lockfile
fi

# Set up environment variables from example
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    echo "⚙️ Setting up environment variables..."
    cp .env.example .env
    
    # Set development defaults
    sed -i 's/your-super-secret-jwt-key-change-in-production/dev-jwt-secret-key-for-codex-environment/g' .env
    sed -i 's/your-refresh-token-secret/dev-refresh-secret-for-codex/g' .env
fi

# Set up database if Docker is available and not already running
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo "🐳 Setting up development databases..."
    
    # Start PostgreSQL and Redis if not running
    if ! docker ps | grep -q postgres; then
        docker-compose up -d postgres redis
        
        # Wait for PostgreSQL to be ready
        echo "⏳ Waiting for PostgreSQL to be ready..."
        timeout 60s bash -c 'until docker-compose exec postgres pg_isready -U postgres; do sleep 2; done'
    fi
    
    # Run database migrations if they exist
    if [ -f "backend/prisma/schema.prisma" ]; then
        echo "🗄️ Running database migrations..."
        cd backend
        npx prisma generate
        npx prisma db push
        cd ..
    elif [ -d "backend/migrations" ]; then
        echo "🗄️ Running database migrations..."
        cd backend
        npm run migrate:up 2>/dev/null || pnpm migrate:up 2>/dev/null || true
        cd ..
    fi
    
    # Seed development data if seed script exists
    if [ -f "backend/scripts/seed.js" ] || [ -f "backend/seeds/index.js" ]; then
        echo "🌱 Seeding development data..."
        cd backend
        npm run seed 2>/dev/null || pnpm seed 2>/dev/null || true
        cd ..
    fi
fi

# Build TypeScript projects
echo "🔨 Building TypeScript projects..."
if [ -f "backend/tsconfig.json" ]; then
    cd backend
    npx tsc --noEmit
    cd ..
fi

if [ -f "frontend/tsconfig.json" ]; then
    cd frontend
    npx tsc --noEmit
    cd ..
fi

# Set up useful aliases in bashrc for this session
echo "⚡ Setting up development aliases..."
cat >> ~/.bashrc << 'EOF'

# PromptCraft Development Aliases
alias ll='ls -alF'
alias ..='cd ..'
alias ...='cd ../..'

# Project navigation
alias cdf='cd frontend'
alias cdb='cd backend'
alias cddb='cd database'

# Package management
alias pi='pnpm install'
alias pr='pnpm run'
alias pb='pnpm build'
alias pt='pnpm test'
alias pd='pnpm dev'

# Database operations
alias dbup='docker-compose up -d postgres redis'
alias dbdown='docker-compose down'
alias dblogs='docker-compose logs -f postgres'
alias psqldev='docker-compose exec postgres psql -U postgres -d promptcraft'
alias rediscli='docker-compose exec redis redis-cli'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gl='git log --oneline'
alias gd='git diff'

# Development helpers
alias logs='tail -f logs/*.log'
alias serve='npx http-server -p 8080'
alias testapi='curl -s http://localhost:8000/health | jq'

# PromptCraft specific
alias start='pnpm run dev'
alias build='pnpm run build'
alias test='pnpm run test'
alias lint='pnpm run lint'
alias migrate='cd backend && pnpm run migrate:up && cd ..'
alias seed='cd backend && pnpm run seed && cd ..'
alias reset='cd backend && pnpm run db:reset && cd ..'
EOF

# Make scripts executable
find . -name "*.sh" -type f -exec chmod +x {} \;

# Create logs directory if it doesn't exist
mkdir -p logs

# Set up git configuration for Codex
git config user.name "Codex Agent" 2>/dev/null || true
git config user.email "codex@promptcraft.dev" 2>/dev/null || true

# Verify setup
echo "✅ Setup verification:"
echo "   Node.js: $(node --version)"
echo "   npm: $(npm --version)"
echo "   pnpm: $(pnpm --version)"
echo "   TypeScript: $(npx tsc --version)"

# Check if databases are accessible
if command -v docker &> /dev/null; then
    if docker-compose ps | grep -q postgres; then
        echo "   PostgreSQL: ✅ Running"
    else
        echo "   PostgreSQL: ⚠️ Not running"
    fi
    
    if docker-compose ps | grep -q redis; then
        echo "   Redis: ✅ Running"
    else
        echo "   Redis: ⚠️ Not running"
    fi
fi

# Check environment file
if [ -f ".env" ]; then
    echo "   Environment: ✅ Configured"
else
    echo "   Environment: ⚠️ Missing .env file"
fi

# Source bashrc to apply aliases
source ~/.bashrc 2>/dev/null || true

echo ""
echo "🎯 PromptCraft environment ready for Codex development!"
echo ""
echo "📁 Project structure:"
echo "   /frontend  - React TypeScript application"
echo "   /backend   - Node.js Express API server"
echo "   /database  - Database migrations and seeds"
echo ""
echo "🔧 Quick commands available:"
echo "   start      - Start development servers"
echo "   build      - Build for production"
echo "   test       - Run test suites"
echo "   migrate    - Run database migrations"
echo "   seed       - Seed development data"
echo "   dbup       - Start databases"
echo "   psqldev    - Access PostgreSQL"
echo ""
echo "🌐 Development URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8000"
echo "   API Health: http://localhost:8000/health"
echo ""
echo "Ready for Codex task execution! 🚀"
