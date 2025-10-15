#!/bin/bash

# Add admin audit logging table to staging database

echo "🔧 Adding admin audit logging table to staging..."

# Get staging connection string
STAGING_CONNECTION_STRING=$(az webapp config appsettings list \
    --resource-group homework-helper-stage-rg-f \
    --name homework-helper-staging \
    --query "[?name=='DATABASE_URL'].value" \
    --output tsv)

echo "✅ Got staging connection string"

# Create admin_audit_log table
echo "📊 Creating admin_audit_log table..."
psql "$STAGING_CONNECTION_STRING" -c "
CREATE TABLE IF NOT EXISTS admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL REFERENCES admin_users(id),
  admin_username VARCHAR(255) NOT NULL,
  admin_email VARCHAR(255) NOT NULL,
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(50) NOT NULL,
  target_id UUID,
  target_email VARCHAR(255),
  target_username VARCHAR(255),
  details JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"

echo "✅ admin_audit_log table created"

# Create indexes
echo "📊 Creating indexes..."
psql "$STAGING_CONNECTION_STRING" -c "
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_admin_user_id ON admin_audit_log(admin_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_created_at ON admin_audit_log(created_at);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_action ON admin_audit_log(action);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_target_type ON admin_audit_log(target_type);
"

echo "✅ Indexes created"

# Show table structure
echo "📋 admin_audit_log table structure:"
psql "$STAGING_CONNECTION_STRING" -c "\d admin_audit_log"

echo ""
echo "🎉 Admin audit logging table setup complete!"
echo ""
echo "📋 What this enables:"
echo "   ✅ Track all admin actions (user deletions, modifications, etc.)"
echo "   ✅ Maintain audit trail for compliance"
echo "   ✅ Identify which admin performed which actions"
echo "   ✅ Log IP addresses and user agents for security"
echo "   ✅ Store action details in JSON format for flexibility"
