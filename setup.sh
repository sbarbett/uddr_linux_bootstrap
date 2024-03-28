#!/bin/bash

# Check if the client ID is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {client_id}"
    exit 1
fi

CLIENT_ID="$1"

# Define the DoH template URL
DOH_URL="https://rcsv.ddr.ultradns.com/${CLIENT_ID}?name=\$q"

# Configure systemd-resolved
sudo mkdir -p /etc/systemd/resolved.conf.d
echo "[Resolve]" | sudo tee /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "DNSOverHTTPS=yes" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "DNS=8.8.8.8" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null # Fallback DNS, change if needed
echo "DNSOverHTTPSAddress=${DOH_URL}" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null

# Restart systemd-resolved to apply changes
sudo systemctl restart systemd-resolved

echo "Setup completed. DNS over HTTPS is configured."
