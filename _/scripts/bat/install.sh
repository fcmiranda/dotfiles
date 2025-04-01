#!/bin/bash

# Script to download and install the latest release of bat (cat clone)
# Installs the binary to $HOME/.local/bin

# Set variables
REPO="sharkdp/bat"
INSTALL_DIR="$HOME/.local/bin"
DOWNLOAD_DIR="$HOME/Downloads"
ASSET_PATTERN="x86_64-unknown-linux-musl.tar.gz" # Adjust if your architecture differs

# Ensure necessary commands are available
if ! command -v curl &> /dev/null; then
  echo "Error: curl is not installed. Please install it."
  exit 1
fi
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it."
  exit 1
fi
if ! command -v tar &> /dev/null; then
  echo "Error: tar is not installed. Please install it."
  exit 1
fi

# Function to download and install the latest bat release
install_latest_bat() {
  local latest_url="https://api.github.com/repos/$REPO/releases/latest"
  local response
  local asset_url
  local download_file

  echo "Fetching latest release information from GitHub..."
  response=$(curl -s "$latest_url")

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to fetch release information from GitHub."
    return 1
  fi

  # Extract the download URL for the specified asset
  asset_url=$(echo "$response" | jq -r --arg PATTERN "$ASSET_PATTERN" '.assets[] | select(.name | endswith($PATTERN)) | .browser_download_url')

  if [[ -z "$asset_url" ]]; then
    echo "Error: Could not find asset matching pattern '$ASSET_PATTERN'."
    echo "Please check available assets at https://github.com/$REPO/releases"
    return 1
  fi

  download_file="$DOWNLOAD_DIR/$(basename "$asset_url")"

  # Download the asset
  echo "Downloading bat from: $asset_url"
  mkdir -p "$DOWNLOAD_DIR"
  if ! curl -L -o "$download_file" "$asset_url"; then
    echo "Error: Failed to download bat."
    return 1
  fi

  # Create installation directory
  mkdir -p "$INSTALL_DIR"

  # Extract the bat binary from the archive directly into the installation directory
  echo "Extracting bat binary to $INSTALL_DIR..."
  # Use --strip-components=1 to remove the top-level directory from the archive
  # Use --wildcards '*/bat' to extract only the 'bat' file itself
  if ! tar -xzf "$download_file" -C "$INSTALL_DIR" --strip-components=1 --wildcards '*/bat'; then
      echo "Error: Failed to extract bat binary."
      rm "$download_file" # Clean up downloaded file
      return 1
  fi

  # Ensure the binary is executable
  chmod +x "$INSTALL_DIR/bat"

  echo "bat installed successfully to $INSTALL_DIR/bat"

  # Clean up downloaded file
  rm "$download_file"

  # Check if INSTALL_DIR is in PATH
  if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "--------------------------------------------------"
    echo "Warning: '$INSTALL_DIR' is not in your PATH."
    echo "You need to add it to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "Then, restart your shell or run 'source ~/.your_shell_rc_file'."
  else
    echo "'$INSTALL_DIR' is already in your PATH."
  fi

  echo "Installation complete."
}

# Run the installation function
install_latest_bat