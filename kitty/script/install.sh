#!/bin/bash

# Set variables
REPO="kovidgoyal/kitty"
DOWNLOAD_DIR="$HOME/Downloads"
INSTALL_DIR="$HOME/.local/kitty"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it."
  exit 1
fi

# Function to get the latest release information and download the correct asset
download_latest_kitty() {
  local url="https://api.github.com/repos/$REPO/releases/latest"
  local response
  local asset_url

  echo "Fetching latest release information from GitHub..."
  response=$(curl -s "$url")

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch release information from GitHub."
    return 1
  fi

  # Extract the browser_download_url for the x86_64 Linux asset
  asset_url=$(echo "$response" | jq -r '.assets[] | select(.name | endswith("x86_64.txz")) | .browser_download_url')
  echo "Extracted asset_url(s) from jq: '$asset_url'"  # Debugging

  if [[ -z "$asset_url" ]]; then
    echo "Error: Could not find x86_64 Linux asset.  Check the repository for available assets."
    return 1
  fi

  # Download the asset
  echo "Downloading Kitty from: $asset_url"
  mkdir -p "$DOWNLOAD_DIR"
#   curl -L -o "$DOWNLOAD_DIR/kitty.tar.gz" "$asset_url" # Change extension if needed

echo $asset_url

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to download Kitty."
    return 1
  fi

#   # Extract the archive
#   echo "Extracting Kitty..."
#   mkdir -p "$INSTALL_DIR"
#   tar -xzf "$DOWNLOAD_DIR/kitty.tar.gz" -C "$INSTALL_DIR"

#   if [[ $? -ne 0 ]]; then
#     echo "Error: Failed to extract Kitty."
#     return 1
#   fi

#   echo "Kitty installed to $INSTALL_DIR"
#   echo "You may need to add $INSTALL_DIR to your PATH."

#   # Clean up downloaded file
#   rm "$DOWNLOAD_DIR/kitty.tar.gz"

  echo "Installation complete."
}

download_latest_kitty
