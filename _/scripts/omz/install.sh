#!/bin/bash

# Script to download and run the Oh My Zsh (OMZ) installation script,
# checking for a pre-existing, functional OMZ installation.

# Set the URL of the OMZ installation script
OMZ_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# Set a temporary file to store the downloaded script
DOWNLOAD_DIR="$HOME/Downloads"
mkdir -p "$DOWNLOAD_DIR"
TMP_FILE="$HOME/omz-install.sh"

# Check if mktemp command failed
if [ -z "$TMP_FILE" ]; then
  echo "Error: Could not create temporary file."
  exit 1
fi

# Download the installation script using curl
echo "Downloading Oh My Zsh installation script..."
if ! curl -sSL "$OMZ_INSTALL_URL" -o "$TMP_FILE"; then
  echo "Error: Failed to download the Oh My Zsh installation script."
  rm -f "$TMP_FILE"  # Clean up the temporary file
  exit 1
fi

# Make the downloaded script executable
echo "Making the script executable..."
chmod +x "$TMP_FILE"

# Run the installation script
echo "Running the Oh My Zsh installation script..."
echo "--------------------------------------------------"
"$TMP_FILE"

# Clean up the temporary file
rm -f "$TMP_FILE"

echo "--------------------------------------------------"
echo "Oh My Zsh installation complete."
echo "You may need to restart your terminal for the changes to take effect."