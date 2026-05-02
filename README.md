# ❄️ My NixOS Flake Configuration

Welcome to my declarative, reproducible, and modular NixOS configuration. This system is built on top of Flakes and Home Manager, allowing for a fully centralized and seamless management experience.

## 🚀 Phase 1: Installation and Deployment

This section outlines the process of applying this configuration to an existing NixOS installation (or when migrating to a newly installed machine).

### 1.1 Cloning the Repository

First, you need to download the configuration to your local machine. By convention, this setup expects the files to reside in the `~/.dotfiles` directory.

Open your terminal and run:

```bash
# Clone the repository into your home directory
git clone <YOUR_REPO_URL> ~/.dotfiles

# Navigate into the configuration directory
cd ~/.dotfiles
```

### 1.2 Basic Setup (Single Source of Truth)

This configuration is designed to be highly portable. You **do not** need to hunt down and manually change paths or usernames across multiple files. The system owner is defined in exactly one place.

1. Open `flake.nix` in your preferred text editor (e.g., `nano flake.nix` or `nvim flake.nix`).
2. Near the top of the `let` block, locate the `myUserName` variable.
3. Change its value to match your current system username:

```nix
# Inside flake.nix
let
  system = "x86_64-linux";
  
  # Change this value to your actual username!
  myUserName = "user17"; 
```

> **⚠️ Important (Hardware Configuration):** 
> Ensure that the `hardware-configuration.nix` file in this directory was generated specifically for **your current machine** (containing the correct disk UUIDs). If you are deploying this on a brand-new computer, generate a fresh hardware profile by running `sudo nixos-generate-config --dir .`. 
> *Crucial:* You must add this new file to Git tracking (`git add hardware-configuration.nix`), otherwise the NixOS flake builder will not be able to see it!

### 1.3 First System Build and the `ossync` Magic

Since this is the initial setup and our configuration hasn't been applied to the OS yet, we must trigger the build command manually using the absolute path.

Run the following command:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#my-pc
```

*(Note: `#my-pc` corresponds to the specific host configuration name defined in the `flake.nix` outputs).*

**✨ The `ossync` Alias:**
Once the initial build completes successfully, the custom `zsh` environment defined in `home.nix` will be activated. This includes a built-in shortcut for all future system updates. 

From now on, whenever you modify your configuration (e.g., install a new package, tweak a setting, or change a theme), you no longer need to type out the full rebuild command. Simply run:

```bash
ossync
```

This simple alias will automatically pull your latest local changes from `~/.dotfiles` and rebuild the system in seconds!

***

## 🛠️ Phase 2: Post-Installation & Secrets Setup

Once the system is built, there are two important components that require manual attention: the secure VPN setup and the Neovim environment.

### 2.1 VPN Configuration (VLESS)

For security reasons, sensitive data like VPN credentials are **not** stored in this Git repository or the public Nix Store. Instead, they are kept in a secure system directory. 

The system uses a custom systemd service (`throne-auto-load`) powered by Sing-Box to manage a **VLESS** protocol connection. Thanks to the `ConditionPathExists` rule, the service will silently sleep until it detects your configuration file.

To activate the VPN, follow these steps:

1. Create a secure directory for the VPN:
   ```bash
   sudo mkdir -p /etc/vpn
   ```
2. Place your VLESS proxy configuration file there and name it exactly `config.json`:
   ```bash
   # Example: copy from a USB drive or download it
   sudo cp /path/to/your/vless-config.json /etc/vpn/config.json
   ```
3. Lock down the permissions so only the `root` user can read it:
   ```bash
   sudo chown root:root /etc/vpn/config.json
   sudo chmod 600 /etc/vpn/config.json
   ```
4. Start the service:
   ```bash
   sudo systemctl start throne-auto-load
   ```

### 2.2 Neovim (NvChad) Environment

This configuration provides a highly customized Neovim experience powered by **NvChad**. 

Because NvChad is a dynamic framework that needs to download plugins, compile parsers, and update its `lazy-lock.json` file on the fly, putting it in the read-only Nix Store would break it. 

To solve this, Home Manager uses `mkOutOfStoreSymlink`. This creates a direct bridge between your system's config folder and this repository.

**How to manage Neovim:**
* **Do not** edit files inside `~/.config/nvim`. That is just a symlink.
* **Do** edit your Neovim files directly inside the `~/.dotfiles/nvim/` directory.
* Any changes you make in `~/.dotfiles/nvim/` will take effect immediately upon restarting Neovim—no `ossync` rebuild is required for Neovim config tweaks!

## 📦 System Overview & Included Packages

### 🖥️ Desktop Environment & UI
* **GNOME with Pop Shell:** The core desktop environment is GNOME, but it is supercharged with the **Pop Shell** extension. This provides advanced, auto-tiling window management (similar to window managers like i3 or bspwm) right inside a stable desktop environment.
* **Vertical Workspaces:** Replaces the default horizontal GNOME workspace layout with a more efficient vertical stack.
* **Theming:** Styled with the `Pop-dark` GTK theme, `Adwaita` icons, `Bibata-Modern-Classic` cursors, and `JetBrainsMono Nerd Font` for a clean, cohesive, and modern look.

### 💻 Terminal & CLI Magic
* **Alacritty & Zellij:** The lightning-fast Alacritty terminal emulator paired with Zellij, a modern terminal multiplexer (configured with a Catppuccin Mocha theme).
* **Zsh Environment:** Zsh comes pre-configured with Oh-My-Zsh, syntax highlighting, autosuggestions, and modern Rust-based CLI utilities:
  * `eza` (a modern replacement for `ls`)
  * `fzf` (command-line fuzzy finder)
  * `ripgrep` & `fd` (blazing fast search tools)
* **File Management:** `yazi` (a lightning-fast terminal file manager) alongside the GUI `nautilus`.
* **System Monitoring:** `htop` (processes), `duf` (disk usage utility), and `gdu` (fast disk usage analyzer).

### 🛠️ Development & Toolchain
* **IDEs & Editors:** Neovim (pre-configured for NvChad), JetBrains PhpStorm (unstable channel for the latest features), and VSCode.
* **Web & APIs:** **Zen Browser** (built directly from Flake inputs) and Postman for API testing.
* **Databases:** DBeaver (GUI database manager) and MariaDB.
* **Core Toolchain:** Docker, NodeJS 22, GCC, and GNU Make.

### 📝 Productivity & Privacy
* **Organization:** Obsidian for personal knowledge management and Todoist for task tracking.
* **Security & Network:** KeePassXC for local, encrypted password management. 
* **Proxy & VPN:** WireGuard tools, Xray, v2raya, and the Throne UI to manage secure, encrypted network routing.
* **Communication & Misc:** Telegram Desktop and Gnumeric (lightweight spreadsheet viewer).
