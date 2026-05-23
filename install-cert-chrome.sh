#!/bin/bash
# Install DYMO web service certificate into Chrome/Chromium
# Run this after Chrome updates if the certificate gets lost (though it shouldn't)

set -e

CERT_PATH="/etc/dymo-web-service/cert.pem"
CERT_NICKNAME="DYMO Web Service (localhost)"
NSS_DB="$HOME/.pki/nssdb"

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

# Check if NSS database exists (Chrome creates it on first run)
if [ ! -d "$NSS_DB" ]; then
    echo "ERROR: Chrome NSS database not found at $NSS_DB"
    echo "Have you run Chrome at least once?"
    exit 1
fi

# Remove old certificate if it exists (to avoid duplicate entries)
certutil -D -d sql:"$NSS_DB" -n "$CERT_NICKNAME" 2>/dev/null || true

# Add the certificate as a trusted CA
echo "Adding certificate to Chrome..."
certutil -A -d sql:"$NSS_DB" -n "$CERT_NICKNAME" -t "C,," -i "$CERT_PATH"

echo "✓ Certificate installed successfully!"
echo ""
echo "To verify, visit: https://127.0.0.1:41952/DYMO/DLS/Printing/Check"
echo "You should see 'true' without any certificate warning."
echo ""
echo "If Chrome ever loses the certificate after an update, just run this script again."
