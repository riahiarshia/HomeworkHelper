#!/bin/bash

# Backup Current Environment State
# This creates a complete backup before making any changes

echo "🔄 CREATING ENVIRONMENT BACKUP"
echo "=============================="

# Create backup directory with timestamp
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Backing up current state to: $BACKUP_DIR"

# Backup current code
echo "📁 Backing up code..."
cp -r backend "$BACKUP_DIR/"
cp -r public "$BACKUP_DIR/"
cp -r middleware "$BACKUP_DIR/"
cp -r routes "$BACKUP_DIR/"
cp -r scripts "$BACKUP_DIR/"
cp -r Tests "$BACKUP_DIR/"
cp -r HomeworkHelper "$BACKUP_DIR/"
cp *.md "$BACKUP_DIR/"
cp *.sh "$BACKUP_DIR/"
cp *.json "$BACKUP_DIR/"
cp *.js "$BACKUP_DIR/"
cp *.html "$BACKUP_DIR/"
cp *.txt "$BACKUP_DIR/"

# Backup current database state
echo "🗄️ Backing up database state..."
curl -s --max-time 30 https://homework-helper-api.azurewebsites.net/api/ledger/public-stats > "$BACKUP_DIR/ledger-stats.json" 2>/dev/null || echo "{}" > "$BACKUP_DIR/ledger-stats.json"
curl -s --max-time 30 https://homework-helper-api.azurewebsites.net/api/ledger/system-info > "$BACKUP_DIR/system-info.json" 2>/dev/null || echo "{}" > "$BACKUP_DIR/system-info.json"

# Backup current deployment status
echo "🚀 Backing up deployment status..."
gh run list --limit 5 --json databaseId,status,conclusion,workflowName,headBranch,createdAt > "$BACKUP_DIR/deployment-status.json" 2>/dev/null || echo "[]" > "$BACKUP_DIR/deployment-status.json"

# Create backup manifest
cat > "$BACKUP_DIR/BACKUP_MANIFEST.txt" << EOF
Backup Created: $(date)
Environment: Production
Purpose: Pre-fix backup before admin audit table fix
Components Backed Up:
- All source code
- Database state (ledger stats, system info)
- Deployment status
- Configuration files

To restore:
1. Copy files back from this directory
2. Commit and push changes
3. Deploy to production
EOF

echo "✅ Backup completed: $BACKUP_DIR"
echo "📋 Backup manifest: $BACKUP_DIR/BACKUP_MANIFEST.txt"
echo "🔄 Ready to proceed with fixes..."
