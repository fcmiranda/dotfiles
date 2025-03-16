# Define variables
REPO="tmux/tmux"
DOWNLOAD_URL="https://api.github.com/repos/$REPO/releases/latest"

# Get the latest release tag
echo "Fetching latest release information..."
TAG=$(curl -s "$DOWNLOAD_URL" | jq -r '.tag_name')

if [ -z "$TAG" ]; then
  echo "Error: Could not retrieve the latest release tag. Check your internet connection and GitHub API rate limits."
  exit 1
fi

echo "Latest release tag: $TAG"

# Construct the download URL
ASSET_NAME="eza_x86_64-unknown-linux-musl.zip"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG/$ASSET_NAME"

echo "Downloading: $DOWNLOAD_URL"

