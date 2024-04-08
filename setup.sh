#!/bin/bash

# Check if a Client ID is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 {client_id}"
    exit 1
fi

CLIENT_ID="$1"

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

# Run the Python script to generate the dnscrypt-proxy.toml file
sudo chmod +x stampgen.py
python3 stampgen.py "${CLIENT_ID}"

# Move the generated dnscrypt-proxy.toml to the appropriate directory
sudo mv dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

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
