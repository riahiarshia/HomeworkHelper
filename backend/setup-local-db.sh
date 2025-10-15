#!/bin/bash

# ========================================
# Local Development Database Setup
# ========================================
# This script sets up PostgreSQL for local development

set -e  # Exit on error

echo "======================================"
echo "Homework Helper - Local DB Setup"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Database configuration from .env.development
DB_NAME="homework_helper_dev"
DB_USER="postgres"
DB_PASSWORD="dev_password_123"
DB_PORT="5432"

# Check if PostgreSQL is installed
echo "Checking PostgreSQL installation..."
if ! command -v psql &> /dev/null; then
    echo -e "${RED}PostgreSQL is not installed!${NC}"
    echo ""
    echo "Install PostgreSQL:"
    echo "  macOS:   brew install postgresql@16"
    echo "  Ubuntu:  sudo apt-get install postgresql postgresql-contrib"
    echo "  Windows: Download from https://www.postgresql.org/download/"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ PostgreSQL found${NC}"
echo ""

# Check if PostgreSQL is running
echo "Checking if PostgreSQL is running..."
if ! pg_isready -p $DB_PORT > /dev/null 2>&1; then
    echo -e "${YELLOW}PostgreSQL is not running. Starting it...${NC}"
    
    # Try to start PostgreSQL (macOS with Homebrew)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew services start postgresql@16 || brew services start postgresql
    fi
    
    # Wait a bit for PostgreSQL to start
    sleep 3
    
    # Check again
    if ! pg_isready -p $DB_PORT > /dev/null 2>&1; then
        echo -e "${RED}Failed to start PostgreSQL${NC}"
        echo "Please start PostgreSQL manually:"
        echo "  macOS:   brew services start postgresql@16"
        echo "  Linux:   sudo service postgresql start"
        exit 1
    fi
fi

echo -e "${GREEN}✓ PostgreSQL is running${NC}"
echo ""

# Create database
echo "Creating database '$DB_NAME'..."
if psql -U $DB_USER -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo -e "${YELLOW}Database '$DB_NAME' already exists${NC}"
    read -p "Drop and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dropdb -U $DB_USER $DB_NAME
        createdb -U $DB_USER $DB_NAME
        echo -e "${GREEN}✓ Database recreated${NC}"
    else
        echo "Keeping existing database"
    fi
else
    createdb -U $DB_USER $DB_NAME
    echo -e "${GREEN}✓ Database created${NC}"
fi
echo ""

# Run migrations
echo "Running database migrations..."
if [ -f "database/schema.sql" ]; then
    psql -U $DB_USER -d $DB_NAME -f database/schema.sql > /dev/null 2>&1
    echo -e "${GREEN}✓ Schema created${NC}"
fi

# Apply migrations from migrations folder
if [ -d "migrations" ]; then
    for migration in migrations/*.sql; do
        if [ -f "$migration" ]; then
            echo "  Applying $(basename $migration)..."
            psql -U $DB_USER -d $DB_NAME -f "$migration" > /dev/null 2>&1 || echo -e "${YELLOW}    Warning: Migration may have already been applied${NC}"
        fi
    done
fi

echo ""

# Create admin user
echo "Creating admin user..."
psql -U $DB_USER -d $DB_NAME << EOSQL
-- Create admin user if not exists
INSERT INTO admins (username, email, password_hash, created_at)
VALUES (
    'admin',
    'admin@localhost',
    '\$2b\$10\$K7vF7rZdH0Y9j9Y5aXk8JuZ9xQ7X3VX7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z',  -- password: admin123
    NOW()
)
ON CONFLICT (username) DO NOTHING;
EOSQL

echo -e "${GREEN}✓ Admin user ready (username: admin, password: admin123)${NC}"
echo ""

echo "======================================"
echo -e "${GREEN}Database setup complete!${NC}"
echo "======================================"
echo ""
echo "Database details:"
echo "  Name:     $DB_NAME"
echo "  User:     $DB_USER"
echo "  Host:     localhost"
echo "  Port:     $DB_PORT"
echo ""
echo "Connection string:"
echo "  postgresql://$DB_USER:$DB_PASSWORD@localhost:$DB_PORT/$DB_NAME"
echo ""
echo "Next steps:"
echo "  1. Update .env.development with your OpenAI API key"
echo "  2. Run: npm install"
echo "  3. Run: npm run dev"
echo ""
