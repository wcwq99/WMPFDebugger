#!/bin/bash

# Quick Start Script for WMPFDebugger + AI_JS_DEBUGGER Integration
# This script helps you set up the AI-powered miniapp reverse engineering environment

set -e

echo "=========================================="
echo "WMPFDebugger + AI_JS_DEBUGGER Integration"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the WMPFDebugger directory
if [ ! -f "package.json" ] || ! grep -q '"name"[[:space:]]*:[[:space:]]*"WMPFDebugger"' package.json; then
    echo -e "${RED}Error: This script must be run from the WMPFDebugger directory${NC}"
    exit 1
fi

WMPF_DIR=$(pwd)
AI_DEBUGGER_DIR="../AI_JS_DEBUGGER"

echo "WMPFDebugger directory: $WMPF_DIR"
echo "AI_JS_DEBUGGER directory: $AI_DEBUGGER_DIR"
echo ""

# Check if AI_JS_DEBUGGER is cloned
if [ ! -d "$AI_DEBUGGER_DIR" ]; then
    echo -e "${YELLOW}AI_JS_DEBUGGER not found. Cloning...${NC}"
    cd ..
    git clone https://github.com/Valerian7/AI_JS_DEBUGGER.git
    cd "$WMPF_DIR"
    echo -e "${GREEN}✓ AI_JS_DEBUGGER cloned successfully${NC}"
else
    echo -e "${GREEN}✓ AI_JS_DEBUGGER directory found${NC}"
fi

# Check Node.js installation
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed. Please install Node.js (LTS v22+)${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js found: $(node --version)${NC}"

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed. Please install Python 3.11+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python found: $(python3 --version)${NC}"

# Check yarn installation
if ! command -v yarn &> /dev/null; then
    echo -e "${YELLOW}Warning: yarn is not installed. Installing yarn...${NC}"
    npm install -g yarn
fi
echo -e "${GREEN}✓ Yarn found${NC}"

echo ""
echo "Installing dependencies..."
echo ""

# Install WMPFDebugger dependencies
echo "Installing WMPFDebugger dependencies..."
yarn install
echo -e "${GREEN}✓ WMPFDebugger dependencies installed${NC}"

# Install AI_JS_DEBUGGER dependencies
if [ -f "$AI_DEBUGGER_DIR/requirements.txt" ]; then
    echo "Installing AI_JS_DEBUGGER dependencies..."
    cd "$AI_DEBUGGER_DIR"
    pip3 install -r requirements.txt
    cd "$WMPF_DIR"
    echo -e "${GREEN}✓ AI_JS_DEBUGGER dependencies installed${NC}"
else
    echo -e "${YELLOW}Warning: AI_JS_DEBUGGER requirements.txt not found${NC}"
fi

echo ""
echo "Copying example configuration..."

# Copy example config if AI_JS_DEBUGGER config doesn't exist
if [ ! -f "$AI_DEBUGGER_DIR/config.yaml" ]; then
    if [ -f "ai_debugger_config.example.yaml" ]; then
        cp ai_debugger_config.example.yaml "$AI_DEBUGGER_DIR/config.yaml"
        echo -e "${GREEN}✓ Configuration file copied to AI_JS_DEBUGGER/config.yaml${NC}"
        echo -e "${YELLOW}⚠ Please edit $AI_DEBUGGER_DIR/config.yaml and set your AI API key${NC}"
    else
        echo -e "${YELLOW}Warning: Example config not found. Please configure AI_JS_DEBUGGER manually${NC}"
    fi
else
    echo -e "${GREEN}✓ AI_JS_DEBUGGER config.yaml already exists${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Edit $AI_DEBUGGER_DIR/config.yaml and set your AI API key"
echo "2. Start WMPFDebugger: npx ts-node src/index.ts"
echo "3. Launch your target miniapp in WeChat"
echo "4. Start AI_JS_DEBUGGER: cd $AI_DEBUGGER_DIR && python3 run_flask.py"
echo "5. Open http://localhost:5001 in your browser"
echo ""
echo "For detailed instructions, see: AI_INTEGRATION.md"
echo ""
