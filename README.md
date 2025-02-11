# Dotfiles Repository

This repository manages configuration files (dotfiles) using **GNU Stow**, a symlink manager that simplifies dotfile organization and deployment across multiple systems.

## Why Use Stow?
Stow automates the management of dotfiles by creating symbolic links from this repository to the appropriate locations in your home directory. This approach keeps everything clean and modular.

## Installation
First, install Stow if you haven't already:

```bash
# On Fedora
sudo dnf install stow

# On Debian/Ubuntu
sudo apt install stow

# On macOS (via Homebrew)
brew install stow
```

## Repository Structure
The repository follows a structured format where each configuration is placed inside a separate directory:

```
.dotfiles/  
│── bash/          # Bash configuration files
│── nvim/          # Neovim configuration files
│── git/           # Git configuration files
│── tmux/          # Tmux configuration files
│── zsh/           # Zsh configuration files
```

Each directory represents an application or tool and contains the actual configuration files, following the same structure as they should appear in `$HOME`.

## Usage
Clone the repository to your home directory:

```bash
git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### Stowing Configurations
To apply a configuration, navigate to the repository and run:

```bash
stow <package-name>
```

For example, to apply your Neovim configuration:

```bash
stow nvim
```

This will create symbolic links from `~/.dotfiles/nvim/` to your home directory, placing files where they belong (e.g., `~/.config/nvim/init.lua`).

### Unstowing Configurations
If you need to remove symlinks without deleting files:

```bash
stow -D <package-name>
```

For example, to remove the Neovim configuration:

```bash
stow -D nvim
```

### Stowing Multiple Configurations
You can apply multiple configurations at once:

```bash
stow bash git nvim tmux zsh
```

## Customization
To modify configurations, simply edit files within this repository. Changes will automatically apply if the symlinks exist.

## Updating Dotfiles
After making changes, commit and push them:

```bash
git add .
git commit -m "Updated configurations"
git push origin main
```

## Troubleshooting
- If symlinks fail due to existing files, back them up and remove conflicts:
  ```bash
  mv ~/.bashrc ~/.bashrc.bak
  stow bash
  ```

- If symlinks are broken, restow everything:
  ```bash
  stow -R *
  ```

## License
This repository is open-source. Feel free to fork and customize it for your needs!

