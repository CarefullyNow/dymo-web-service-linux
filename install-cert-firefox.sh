#!/bin/bash
# Install DYMO web service certificate into Firefox
# Run this after Firefox updates if the certificate gets lost (though it shouldn't)

set -e

CERT_PATH="/etc/dymo-web-service/cert.pem"
CERT_NICKNAME="DYMO Web Service (localhost)"

# Check if certificate exists
if [ ! -f "$CERT_PATH" ]; then
    echo "ERROR: Certificate not found at $CERT_PATH"
    exit 1
fi

# Check if NSS tools are installed
if ! command -v certutil &> /dev/null; then
    echo "Installing NSS tools..."
    sudo apt-get update
    sudo apt-get install -y libnss3-tools
fi

# Find Firefox profile directory
FIREFOX_PROFILES="$HOME/.mozilla/firefox"
if [ ! -d "$FIREFOX_PROFILES" ]; then
    echo "ERROR: Firefox profile directory not found at $FIREFOX_PROFILES"
    echo "Have you run Firefox at least once?"
    exit 1
fi

# Find default profile (look for *.default-release or *.default)
PROFILE_DIR=$(find "$FIREFOX_PROFILES" -maxdepth 1 -type d -name "*.default-release" -o -name "*.default" | head -1)

if [ -z "$PROFILE_DIR" ]; then
    echo "ERROR: Could not find Firefox profile directory"
    exit 1
fi

echo "Found Firefox profile: $PROFILE_DIR"

# Remove old certificate if it exists
certutil -D -d sql:"$PROFILE_DIR" -n "$CERT_NICKNAME" 2>/dev/null || true

# Add the certificate as a trusted CA
echo "Adding certificate to Firefox..."
certutil -A -d sql:"$PROFILE_DIR" -n "$CERT_NICKNAME" -t "C,," -i "$CERT_PATH"

echo "✓ Certificate installed successfully!"
echo ""
echo "To verify, visit: https://127.0.0.1:41952/DYMO/DLS/Printing/Check"
echo "You should see 'true' without any certificate warning."
echo ""
echo "If Firefox ever loses the certificate after an update, just run this script again."
