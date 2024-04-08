#!/usr/bin/env python3

import argparse
import base64
import re

def make_stamp(input_string):
    # Strip trailing newline characters from the input string
    input_string = input_string.rstrip('\n')

    # This pattern matches hexadecimal escape sequences
    hex_pattern = re.compile(r'\\x([0-9a-fA-F]{2})')
    
    # Convert recognized hex escape sequences to bytes, leaving other characters intact
    bytes_list = []
    last_end = 0
    for match in hex_pattern.finditer(input_string):
        # Add previous ASCII part
        bytes_list.append(input_string[last_end:match.start()].encode('utf-8'))
        # Convert hex escape to byte and add to list
        bytes_list.append(bytes([int(match.group(1), 16)]))
        last_end = match.end()
    
    # Add remaining ASCII part after the last match
    bytes_list.append(input_string[last_end:].encode('utf-8'))
    
    # Combine all parts into one bytes object
    combined_bytes = b''.join(bytes_list)
    
    # Encode these bytes into base64
    encoded_base64 = base64.b64encode(combined_bytes).decode('utf-8')
    
    return encoded_base64

def write_toml_file(rcsv1_stamp, rcsv2_stamp):
    content = f"""server_names = ['custom-uddr1', 'custom-uddr2']
listen_addresses = ['127.0.0.5:53'] # Ensure dnscrypt-proxy listens on port 53

[static.'custom-uddr1']
stamp = 'sdns://{rcsv1_stamp}'

[static.'custom-uddr2']
stamp = 'sdns://{rcsv2_stamp}'
"""
    with open('dnscrypt-proxy.toml', 'w') as f:
        f.write(content)

def main():
    parser = argparse.ArgumentParser(description='Encode a string to base64.')
    parser.add_argument('input_string', type=str, help='The string to encode')
    args = parser.parse_args()

    rcsv1_info = f"\x02\x07\x00\x00\x00\x00\x00\x00\x00\x0c204.74.103.5\x00\x16rcsv1.ddr.ultradns.com%/{args.input_string}"
    rcsv2_info = f"\x02\x07\x00\x00\x00\x00\x00\x00\x00\x0c204.74.122.5\x00\x16rcsv2.ddr.ultradns.com%/{args.input_string}"
    
    rcsv1_stamp = make_stamp(rcsv1_info)
    rcsv2_stamp = make_stamp(rcsv2_info)

    write_toml_file(rcsv1_stamp, rcsv2_stamp)

    print("dnscrypt-proxy.toml has been generated with the provided stamps.")

if __name__ == "__main__":
    main()