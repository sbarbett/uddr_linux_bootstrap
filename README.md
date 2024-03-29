# uddr_linux_bootstrap

This script demonstrates the setup of Vercara's UltraDDR product on a Linux system, configuring it to use custom DNS over HTTPS (DoH) servers and routing system's DNS queries through `dnscrypt-proxy` for enhanced privacy and blocking.

## Prerequisites

- Ubuntu (I tested this on Ubuntu and adjustments may be needed for other Linux distributions)
- Sudo privileges

## Generating DNSCrypt Stamps

Before running the script, generate your DNSCrypt stamps:

1. Visit [DNSCrypt](https://dnscrypt.info/stamps/).
2. Change the **Protocol** to **DNS-over-HTTPS**.
2. Generate the first stamp:
   - **IP**: `204.74.103.5`
   - **Host**: `rcsv1.ddr.ultradns.com`
   - **Path**: `/{your_uddr_client_id}` (Replace `{your_uddr_client_id}` with your unique client ID)
3. Generate the second stamp:
   - **IP**: `204.74.122.5`
   - **Host**: `rcsv2.ddr.ultradns.com`
   - **Path**: Use the same path as the first stamp.

## Installation and Configuration

1. Clone this repository:
   ```bash
   git clone https://github.com/sbarbett/uddr_linux_bootstrap
   ```
1. Make the setup file executable:
   ```bash
   cd uddr_linux_bootstrap
   chmod +x setup.sh
   ```
2. Execute the script, passing your stamps as arguments:
   ```bash
   sudo ./setup.sh {dnscrypt_stamp1} {dnscrypt_stamp2}
   ```
   Replace `{dnscrypt_stamp1}` and `{dnscrypt_stamp2}` with the stamps generated in the previous step.

## Script Functions

- Installs `dnscrypt-proxy`.
- Stops/disables any existing `dnscrypt-proxy` service to prevent conflicts.
- Configures `dnscrypt-proxy` to use your specified DoH servers.
- Adjusts `dnscrypt-proxy` to listen on `127.0.0.5:53`.
- Redirects the system's DNS queries to `dnscrypt-proxy`.
- Applies the configuration changes by restarting related services.

## License

This script is provided under the MIT License. See the LICENSE.md for the full declaration.

