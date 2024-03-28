#!/bin/bash

# Check if DNSCrypt stamp is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {dnscrypt_stamp}"
    exit 1
fi
DNSCRYPT_STAMP="$1"

# Install dnscrypt-proxy. This example uses apt, adjust for your package manager if necessary
sudo apt update && sudo apt install -y dnscrypt-proxy

# Stop systemd-resolved to avoid port conflict during configuration
sudo systemctl stop systemd-resolved

# Configure dnscrypt-proxy to use your custom DoH server
sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy.toml > /dev/null <<EOF
server_names = ['custom-uddr']
listen_addresses = ['127.0.0.2:53'] # Ensure dnscrypt-proxy listens on port 53
require_dnssec = false
require_nolog = true
require_nofilter = true

[static.'custom-uddr']
stamp = '${DNSCRYPT_STAMP}'
EOF

# Restart dnscrypt-proxy to apply the configuration
sudo systemctl restart dnscrypt-proxy

# Configure systemd-resolved to use the local dnscrypt-proxy as the DNS server
sudo mkdir -p /etc/systemd/resolved.conf.d
echo "[Resolve]" | sudo tee /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "DNS=127.0.0.2" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "FallbackDNS=8.8.8.8 8.8.4.4" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null

# Re-enable and restart systemd-resolved to apply changes
sudo systemctl enable systemd-resolved
sudo systemctl restart systemd-resolved

echo "Setup completed. DNS over HTTPS is configured using dnscrypt-proxy."
