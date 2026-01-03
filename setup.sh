#!/bin/bash

set -e

echo "🚀 Setting up Kestrel development environment..."

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required but not installed. Aborting." >&2; exit 1; }
command -v cargo >/dev/null 2>&1 || { echo "❌ Rust/Cargo is required but not installed. Aborting." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 is required but not installed. Aborting." >&2; exit 1; }

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend
npm install
cd ..

# Set up Python virtual environment
echo "🐍 Setting up Python virtual environment..."
cd ai-layer
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "✅ Created Python virtual environment"
else
    echo "✅ Python virtual environment already exists"
fi

source .venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install -e .
cd ..

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the app:"
echo "  npm run dev"
echo ""
echo "To activate Python virtual environment later:"
echo "  cd ai-layer && source .venv/bin/activate"

