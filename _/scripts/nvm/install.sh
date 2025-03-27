#!/bin/bash

# Script to download and run the nvm installation script

# Set the URL of the nvm installation script
NVM_INSTALL_URL="https://github.com/nvm-sh/nvm/blob/master/install.sh"

# Set a temporary file to store the downloaded script
DOWNLOAD_DIR="$HOME/Downloads"
mkdir -p "$DOWNLOAD_DIR"
TMP_FILE="$HOME/nvm-install.sh"

# Check if mktemp command failed
if [ -z "$TMP_FILE" ]; then
  echo "Error: Could not create temporary file."
  exit 1
fi

# Download the installation script using curl
echo "Downloading nvm installation script..."
if ! curl -sSL "$NVM_INSTALL_URL?raw=true" -o "$TMP_FILE"; then
  echo "Error: Failed to download the nvm installation script."
  rm -f "$TMP_FILE"  # Clean up the temporary file
  exit 1
fi

# Make the downloaded script executable
echo "Making the script executable..."
chmod +x "$TMP_FILE"

# Run the installation script
echo "Running the nvm installation script..."
echo "--------------------------------------------------"
"$TMP_FILE"

# Clean up the temporary file
rm -f "$TMP_FILE"

echo "--------------------------------------------------"
echo "nvm installation complete."
echo "Remember to add the following to your .bashrc, .zshrc, .profile, or equivalent:"
echo ". \$HOME/.nvm/nvm.sh"
echo "(You may also need to source the file where you added the line)"
echo "To verify the installation, open a new terminal or source your shell configuration and run 'nvm --version'."