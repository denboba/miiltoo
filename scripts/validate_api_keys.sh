#!/bin/bash

# Google Maps API Key Validation Script
# This script checks if API keys are properly configured

echo "======================================"
echo "Google Maps API Key Validation"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
echo "1. Checking .env file..."
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env file found"
    
    # Check for required keys
    echo ""
    echo "2. Checking required API keys in .env..."
    
    keys=(
        "GOOGLE_MAPS_WEB_API_KEY"
        "GOOGLE_DIRECTIONS_API_KEY"
        "GOOGLE_MAPS_ANDROID_API_KEY"
        "GOOGLE_MAPS_IOS_API_KEY"
    )
    
    missing_keys=0
    placeholder_keys=0
    
    for key in "${keys[@]}"; do
        if grep -q "^${key}=" .env; then
            value=$(grep "^${key}=" .env | cut -d'=' -f2)
            if [ -z "$value" ] || [ "$value" = "YOUR_API_KEY_HERE" ]; then
                echo -e "${YELLOW}⚠${NC} ${key} is set but uses placeholder value"
                ((placeholder_keys++))
            else
                echo -e "${GREEN}✓${NC} ${key} is configured"
            fi
        else
            echo -e "${RED}✗${NC} ${key} is missing"
            ((missing_keys++))
        fi
    done
else
    echo -e "${RED}✗${NC} .env file not found"
    echo -e "${YELLOW}→${NC} Create it by running: cp .env.example .env"
    exit 1
fi

echo ""
echo "3. Checking platform-specific configurations..."

# Check Android manifest
if grep -q "YOUR_GOOGLE_MAPS_API_KEY" android/app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} AndroidManifest.xml still has placeholder API key"
else
    echo -e "${GREEN}✓${NC} Android API key appears to be configured"
fi

# Check iOS AppDelegate
if [ -f "ios/Runner/AppDelegate.swift" ]; then
    if grep -q "// GMSServices.provideAPIKey" ios/Runner/AppDelegate.swift; then
        echo -e "${YELLOW}⚠${NC} iOS AppDelegate.swift has commented out API key"
    elif grep -q "GMSServices.provideAPIKey" ios/Runner/AppDelegate.swift; then
        if grep -q "YOUR_IOS_API_KEY" ios/Runner/AppDelegate.swift; then
            echo -e "${YELLOW}⚠${NC} iOS AppDelegate.swift still has placeholder API key"
        else
            echo -e "${GREEN}✓${NC} iOS API key appears to be configured"
        fi
    else
        echo -e "${YELLOW}⚠${NC} iOS API key not configured in AppDelegate.swift"
    fi
fi

# Check web config
if [ -f "web/google_maps_config.js" ]; then
    if grep -q "YOUR_WEB_API_KEY_HERE" web/google_maps_config.js; then
        echo -e "${YELLOW}⚠${NC} web/google_maps_config.js still has placeholder API key"
    else
        echo -e "${GREEN}✓${NC} Web API key appears to be configured"
    fi
else
    echo -e "${YELLOW}⚠${NC} web/google_maps_config.js not found (optional for web builds)"
fi

echo ""
echo "======================================"
echo "Summary"
echo "======================================"

if [ $missing_keys -eq 0 ] && [ $placeholder_keys -eq 0 ]; then
    echo -e "${GREEN}All API keys are configured!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Verify your API keys are valid in Google Cloud Console"
    echo "2. Ensure required APIs are enabled (Maps SDK, Directions API)"
    echo "3. Run 'flutter pub get' to install dependencies"
    echo "4. Run the app: flutter run"
else
    if [ $missing_keys -gt 0 ]; then
        echo -e "${RED}Missing keys: ${missing_keys}${NC}"
    fi
    if [ $placeholder_keys -gt 0 ]; then
        echo -e "${YELLOW}Placeholder keys: ${placeholder_keys}${NC}"
    fi
    echo ""
    echo "Please update your .env file with actual API keys."
    echo "See docs/API_KEYS_SETUP.md for detailed instructions."
fi

echo ""
