#!/bin/bash

echo "🚀 Starting Homework Helper Backend..."

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
fi

# Start the server
echo "🌐 Starting server..."
node server.js
