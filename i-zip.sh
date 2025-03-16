ZIP_URL=https://github.com/tmux/tmux/archive/refs/heads/master.zip
DOWNLOAD_DIR=$HOME/Downloads
INSTALL_DIR="$HOME/felipe"

# Download and extract
echo "Downloading: $ZIP_URL"
curl -L https://github.com/tmux/tmux/archive/refs/heads/master.zip -o tmux.zip

# unzip $DOWNLOAD_DIR/tmux-master.zip -d $DOWNLOAD_DIR/tmux
# cd $DOWNLOAD_DIR/tmux
# sh autogen.sh
# ./configure --prefix="$INSTALL_DIR" && make