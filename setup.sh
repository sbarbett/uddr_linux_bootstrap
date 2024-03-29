#!/bin/bash

# Check if DNSCrypt stamps are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 {dnscrypt_stamp1} {dnscrypt_stamp2}"
    exit 1
fi

DNSCRYPT_STAMP1="$1"
DNSCRYPT_STAMP2="$2"

# Install dnscrypt-proxy. This example uses apt, adjust for your package manager if necessary
sudo apt update && sudo apt install -y dnscrypt-proxy

# Before configuring dnscrypt-proxy, ensure any existing instance is stopped and disabled to avoid conflicts
sudo systemctl stop dnscrypt-proxy.service
sudo systemctl stop dnscrypt-proxy.socket
sudo systemctl disable dnscrypt-proxy.socket
sudo systemctl disable dnscrypt-proxy.service

# Remove possibly conflicting systemd unit files (if they exist) to clean up previous configurations
sudo rm -f /lib/systemd/system/dnscrypt-proxy.service /lib/systemd/system/dnscrypt-proxy.socket
sudo rm -rf /var/lib/systemd/deb-systemd-helper-enabled/dnscrypt-proxy.*

# Reload the systemd daemon and reset any failed units
sudo systemctl daemon-reload
sudo systemctl reset-failed

# Configure dnscrypt-proxy to use custom DoH servers
sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy.toml > /dev/null <<EOF
server_names = ['custom-uddr1', 'custom-uddr2']
listen_addresses = ['127.0.0.5:53'] # Ensure dnscrypt-proxy listens on port 53

[static.'custom-uddr1']
stamp = '${DNSCRYPT_STAMP1}'

[static.'custom-uddr2']
stamp = '${DNSCRYPT_STAMP2}'
EOF

# Install dnscrypt-proxy as a service using the newly configured settings
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -service install

# Start dnscrypt-proxy service
sudo service dnscrypt-proxy start

#### UDDR Certificate Installation #####
wget https://ca.ultraddr.com/cert/pem/ultraddr-ca-cert.pem
sudo mv ultraddr-ca-cert.pem /usr/local/share/ca-certificates/ultraddr.crt
sudo update-ca-certificates
#######################################

# Configure systemd-resolved to use the local dnscrypt-proxy as the DNS server
sudo mkdir -p /etc/systemd/resolved.conf.d
echo "[Resolve]" | sudo tee /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "DNSStubListener=no" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "DNS=127.0.0.5" | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null
echo "Domains=~." | sudo tee -a /etc/systemd/resolved.conf.d/uddr.conf > /dev/null

# Re-enable and restart systemd-resolved to apply changes
sudo systemctl restart systemd-resolved

echo "Setup completed. DNS over HTTPS is configured using dnscrypt-proxy."
