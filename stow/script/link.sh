#!/bin/bash
# Script: stow_local.sh
# Description: Creates or removes symbolic links to files in child folders to ~/
# Usage: stow_local.sh [-r] [source_dir]
#   -r: Remove symbolic links instead of creating them.
#   source_dir: The directory containing the child folders with files to link.
#                If omitted, defaults to the current directory.

# --- Configuration ---

TARGET_DIR="$HOME"

# --- Argument Parsing ---

REMOVE_MODE=0
SOURCE_DIR="$PWD" # Default to current directory

while getopts "r" opt; do
  case "$opt" in
    r)
      REMOVE_MODE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

if [ $# -gt 1 ]; then
  echo "Error: Too many arguments.  Only one source directory allowed."
  exit 1
fi

if [ $# -eq 1 ]; then
  if [ -d "$1" ]; then
    SOURCE_DIR="$1"
  else
    echo "Error: Directory \"$1\" does not exist."
    exit 1
  fi
fi

# --- Functions ---

create_link() {
  local target_link="$1"
  local source_file="$2"
  echo "Creating symbolic link: $target_link -> $source_file"
  ln -s "$source_file" "$target_link"
}

remove_link() {
  local target_link="$1"
  echo "Removing symbolic link: $target_link"
  rm "$target_link"
}

# --- Main Logic ---

if [ "$REMOVE_MODE" -eq 1 ]; then
  echo "Removing symbolic links from $TARGET_DIR to files under $SOURCE_DIR."
else
  echo "Creating symbolic links from $TARGET_DIR to files under $SOURCE_DIR."
fi

find "$SOURCE_DIR" -type f -print0 | while IFS= read -r -d $'\0' source_file; do
  # Get relative path from SOURCE_DIR to the file
  rel_path=$(echo "$source_file" | sed "s|^$SOURCE_DIR/||") # remove leading SOURCE_DIR/
  target_link="$TARGET_DIR/$rel_path"

  if [ "$REMOVE_MODE" -eq 1 ]; then
    if [ -L "$target_link" ]; then
      remove_link "$target_link"
      if [ $? -ne 0 ]; then
        echo "Error removing link: $target_link"
        exit 1
      fi
    else
      echo "Skipping missing link: $target_link"
    fi

  else
    # Create parent directory if it doesn't exist
    target_dir=$(dirname "$target_link")

    if [ ! -d "$target_dir" ]; then
      echo "Creating directory: $target_dir"
      mkdir -p "$target_dir"
      if [ $? -ne 0 ]; then
        echo "Error creating directory: $target_dir"
        exit 1
      fi
    fi

    if [ ! -e "$target_link" ]; then
      create_link "$target_link" "$source_file"
      if [ $? -ne 0 ]; then
        echo "Error creating link from $source_file to $target_link"
        exit 1
      fi
    else
      echo "Skipping existing file: $target_link" # Could be a file, a directory, or a link. We skip it
    fi
  fi
done

echo
echo "Done."

exit 0