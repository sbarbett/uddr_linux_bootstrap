# uddr_linux_bootstrap

This script demonstrates the setup of Vercara's UltraDDR product on a Linux system, configuring it to use custom DNS over HTTPS (DoH) servers and routing system's DNS queries through `dnscrypt-proxy` for enhanced privacy and blocking.

## Prerequisites

- Ubuntu (I tested this on Ubuntu and adjustments may be needed for other Linux distributions)
- Python
- Sudo privileges

## Installation and Configuration

1. Clone this repository:
   ```bash
   git clone https://github.com/sbarbett/uddr_linux_bootstrap
   ```
2. Make the setup file executable:
   ```bash
   cd uddr_linux_bootstrap
   chmod +x setup.sh
   ```
3. Execute the script:
   ```bash
   sudo ./setup.sh {client_id)
   ```
   Replace `{client_id}` with your UDDR client UID (it's also called an install key in the settings).

## Script Functions

- Installs `dnscrypt-proxy`.
- Stops/disables any existing `dnscrypt-proxy` service to prevent conflicts.
- Configures `dnscrypt-proxy` to use UDDR DNS resolvers linked to your client ID.
- Adjusts `dnscrypt-proxy` to listen on `127.0.0.5:53`.
- Redirects the system's DNS queries to `dnscrypt-proxy`.
- Applies the configuration changes by restarting related services.

## License

This script is provided under the MIT License. See the LICENSE.md for the full declaration.

