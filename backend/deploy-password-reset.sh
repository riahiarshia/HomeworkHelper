#!/bin/bash

# Password Reset Deployment Script
# Run this after setting up SendGrid

echo "
╔════════════════════════════════════════════════════╗
║                                                    ║
║   📧 Password Reset Deployment                    ║
║                                                    ║
╚════════════════════════════════════════════════════╝
"

# Check if DATABASE_URL is set
if [ -z "$DATABASE_URL" ]; then
    echo "❌ Error: DATABASE_URL environment variable not set"
    echo "Set it first: export DATABASE_URL='postgresql://...'"
    exit 1
fi

# Check if SENDGRID_API_KEY is set
if [ -z "$SENDGRID_API_KEY" ]; then
    echo "⚠️  Warning: SENDGRID_API_KEY not set"
    echo "Emails won't send until you set it"
fi

echo "📊 Running database migration..."
echo ""

# Run the migration
psql "$DATABASE_URL" -f database/password-reset-migration.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database migration completed successfully!"
    echo ""
    echo "🎯 Next steps:"
    echo ""
    echo "1. Set SendGrid environment variables:"
    echo "   SENDGRID_API_KEY=your_key"
    echo "   SENDGRID_FROM_EMAIL=noreply@yourdomain.com"
    echo ""
    echo "2. Set app URL:"
    echo "   APP_URL=homeworkhelper://"
    echo ""
    echo "3. Restart your server"
    echo ""
    echo "4. Test password reset!"
    echo ""
else
    echo ""
    echo "❌ Migration failed. Check the error above."
    echo ""
    exit 1
fi

