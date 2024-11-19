#!/bin/bash
API_URL="https://api.github.com/repos/projectdiscovery/nuclei/releases/latest"
TEMP_DIR=$(mktemp -d)
ZIP_URL=$(curl -s "$API_URL" | jq -r '.assets[] | select(.name | test("nuclei.*_linux_amd64.zip")) | .browser_download_url')
if [ -z "$ZIP_URL" ]; then
  echo "Failed to retrieve the download URL."
  exit 1
fi
wget -q "$ZIP_URL" -O "$TEMP_DIR/nuclei.zip"
unzip -o "$TEMP_DIR/nuclei.zip" -d "$TEMP_DIR"
chmod +x "$TEMP_DIR/nuclei"
sudo mv "$TEMP_DIR/nuclei" /usr/local/bin/
rm -rf "$TEMP_DIR"
