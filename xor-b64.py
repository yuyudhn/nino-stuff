import base64
import argparse

def xor_encrypt(data, key):
    encrypted = ''.join(chr(ord(data[i]) ^ ord(key[i % len(key)])) for i in range(len(data)))
    return encrypted

def main():
    parser = argparse.ArgumentParser(description="Encrypt a PowerShell script using XOR encryption and encode it with Base64.")
    parser.add_argument('--input', required=True, help='Input PowerShell script file')
    parser.add_argument('--output', required=True, help='Output encrypted file')
    parser.add_argument('--key', default='nullnet', help='Encryption key (default: nullnet)')
    
    args = parser.parse_args()

    with open(args.input, 'r') as file:
        data = file.read()

    encrypted_data = xor_encrypt(data, args.key)
    encoded_data = base64.b64encode(encrypted_data.encode('utf-16le')).decode('utf-8')

    with open(args.output, 'w') as file:
        file.write(encoded_data)

    print(f'Encrypted script written to {args.output}')

if __name__ == '__main__':
    main()
