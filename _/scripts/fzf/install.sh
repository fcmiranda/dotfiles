#!/bin/bash

# Script to download and run the fzf installation script,
# checking for a pre-existing, functional fzf installation.

# Set the URL of the fzf installation script
FZF_INSTALL_URL="https://github.com/junegunn/fzf/blob/master/install"

# Set a temporary file to store the downloaded script
DOWNLOAD_DIR="$HOME/Downloads"
mkdir -p "$DOWNLOAD_DIR"
TMP_FILE="$HOME/fzf-install.sh"

# Check if mktemp command failed
if [ -z "$TMP_FILE" ]; then
  echo "Error: Could not create temporary file."
  exit 1
fi

# Download the installation script using curl
echo "Downloading fzf installation script..."
if ! curl -sSL "$FZF_INSTALL_URL?raw=true" -o "$TMP_FILE"; then
  echo "Error: Failed to download the fzf installation script."
  rm -f "$TMP_FILE"  # Clean up the temporary file
  exit 1
fi

# Make the downloaded script executable
echo "Making the script executable..."
chmod +x "$TMP_FILE"

# Run the installation script
echo "Running the fzf installation script..."
echo "--------------------------------------------------"
"$TMP_FILE"

# Clean up the temporary file
rm -f "$TMP_FILE"

echo "--------------------------------------------------"
echo "fzf installation complete."
echo "You may need to restart your terminal for the changes to take effect."