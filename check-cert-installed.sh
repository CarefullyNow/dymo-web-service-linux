#!/bin/bash
# Check if DYMO certificate is installed in browsers

CERT_NICKNAME="DYMO Web Service (localhost)"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Checking DYMO certificate installation..."
echo ""

# Check Chrome/Chromium
CHROME_DB="$HOME/.pki/nssdb"
if [ -d "$CHROME_DB" ]; then
    if command -v certutil &> /dev/null; then
        if certutil -L -d sql:"$CHROME_DB" 2>/dev/null | grep -q "$CERT_NICKNAME"; then
            echo -e "Chrome/Chromium: ${GREEN}✓ Certificate installed${NC}"
        else
            echo -e "Chrome/Chromium: ${RED}✗ Certificate NOT installed${NC}"
            echo "  Run: ./install-cert-chrome.sh"
        fi
    else
        echo "Chrome/Chromium: ? (certutil not installed)"
        echo "  Run: sudo apt-get install libnss3-tools"
    fi
else
    echo "Chrome/Chromium: (not found - have you run Chrome?)"
fi

echo ""

# Check Firefox
FIREFOX_PROFILES="$HOME/.mozilla/firefox"
if [ -d "$FIREFOX_PROFILES" ]; then
    PROFILE_DIR=$(find "$FIREFOX_PROFILES" -maxdepth 1 -type d -name "*.default-release" -o -name "*.default" 2>/dev/null | head -1)
    if [ -n "$PROFILE_DIR" ]; then
        if command -v certutil &> /dev/null; then
            if certutil -L -d sql:"$PROFILE_DIR" 2>/dev/null | grep -q "$CERT_NICKNAME"; then
                echo -e "Firefox: ${GREEN}✓ Certificate installed${NC}"
            else
                echo -e "Firefox: ${RED}✗ Certificate NOT installed${NC}"
                echo "  Run: ./install-cert-firefox.sh"
            fi
        else
            echo "Firefox: ? (certutil not installed)"
            echo "  Run: sudo apt-get install libnss3-tools"
        fi
    else
        echo "Firefox: (profile not found - have you run Firefox?)"
    fi
else
    echo "Firefox: (not found - have you run Firefox?)"
fi

echo ""
echo "To test, visit: https://127.0.0.1:41952/DYMO/DLS/Printing/Check"
echo "You should see 'true' without certificate warnings."
