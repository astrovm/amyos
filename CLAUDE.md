# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Amy OS is a custom container-based Linux distribution built on Fedora 42 and Bazzite, optimized for gaming, development, and daily use. It uses OCI containers with bootc for immutable OS deployment and features KDE Plasma 6.3 with SteamOS theming.

## Common Development Commands

### Container Image Building
```bash
# Build container image (default: amyos:latest)
just build [target_image] [tag]

# Examples
just build                    # builds amyos:latest  
just build aurora lts         # builds aurora:lts
```

### Bootable Image Creation
```bash
# VM images for testing
just build-qcow2             # Creates QCOW2 VM image
just build-raw               # Creates raw disk image
just build-iso               # Creates installer ISO

# VM testing
just run-vm-qcow2           # Run VM in browser (auto-opens localhost:8006)
just spawn-vm               # Run with systemd-vmspawn
```

### Code Quality
```bash
just lint                   # Run shellcheck on all .sh files
just format                 # Run shfmt on all .sh files
just check                  # Check Just syntax
just fix                    # Fix Just syntax
just clean                  # Clean build artifacts
```

## Architecture Overview

### Build System
- **Primary**: Podman/Docker containerized builds using `Containerfile`
- **Bootable Images**: Bootc Image Builder (BIB) converts containers to bootable images
- **Task Runner**: Just (Justfile) manages all build operations
- **Base Image**: ghcr.io/ublue-os/bazzite:stable (Fedora 42)

### Directory Structure
- `build_files/`: Build scripts and automation
  - `install-apps.sh`: Main application installation
  - `cleanup.sh`: Post-build optimization
- `system_files/`: OS customization files organized by filesystem path
  - `etc/`: System configuration (DNS, NetworkManager, repositories)
  - `usr/share/amyos/just/`: Custom ujust commands in `amy.just`
- `repo_files/`: Package lists and assets
  - `flatpaks`: 42 curated Flatpak applications
  - `brews`: 19 Homebrew CLI tools
  - `appimages`: AppImage applications
- `disk_config/`: BIB configurations for different image types

### Container Registry & Deployment
- **Registry**: ghcr.io/astrovm/amyos:latest
- **Installation**: `sudo bootc switch --enforce-container-sigpolicy ghcr.io/astrovm/amyos:latest`
- **New Systems**: Install Bazzite ISO first, then switch

## Key Technologies

### Package Management
- **System packages**: Layered in container build
- **Flatpaks**: GUI applications via Discover/FlatHub
- **Homebrew**: CLI tools (`brew install ...`)
- **AppImages**: Portable applications

### Development Stack
- **Editors**: VSCode, Cursor (with Remote Tunnels), Neovim
- **Containers**: Docker, Podman, Distrobox, Toolbx
- **Shell**: Zsh with Starship prompt, Atuin history (Ctrl+R), thefuck alias
- **VM/Containers**: QEMU, libvirt, Virt-Manager

### Gaming Optimizations
- **Base**: Bazzite gaming optimizations
- **GPU**: AMD/Intel optimization
- **Steam**: SteamOS session switching from login screen
- **Mods**: Sonic Adventure (SADX/SA2) setup scripts

## Custom User Commands (ujust)

All user-facing commands are defined in `system_files/usr/share/amyos/just/amy.just`:

```bash
ujust amy-install           # Install all curated applications
ujust amy-install-flatpaks  # Install only Flatpaks
ujust amy-install-brews     # Install only Homebrew tools
ujust amy-install-appimages # Install only AppImages
ujust amy-setup-editors     # Setup Cursor and VSCode configurations
ujust amy-setup-ghostty     # Setup Ghostty terminal configuration
ujust amy-setup-shells      # Configure zsh/bash environments
ujust amy-setup-samods      # Setup Sonic Adventure mods (SADX and SA2)
ujust amy-fix-bt            # Restart Bluetooth to fix issues
ujust amy-ssd-crypto        # Manage SSD encryption optimizations
ujust amy-clean             # Clean old packages and container images
```

## Build Process Flow

1. **Container Build**: `Containerfile` defines base system with layered packages
2. **App Installation**: `build_files/install-apps.sh` installs package lists
3. **System Configuration**: `system_files/` overlay provides customizations
4. **Cleanup**: `build_files/cleanup.sh` optimizes final image
5. **Bootable Conversion**: BIB converts container to VM/ISO images

## File Conventions

- Shell scripts use shellcheck/shfmt linting
- System files follow FHS structure under `system_files/`
- Package lists are simple text files (one per line)
- Just recipes follow grouped organization
- All builds are reproducible and use version control

## Testing & Validation

- **VM Testing**: Use `just run-vm-qcow2` for browser-based testing
- **Local Testing**: Use `just spawn-vm` for systemd-vmspawn
- **Build Validation**: `just lint` and `just format` for code quality
- **Package Testing**: Install on Bazzite VM, then switch with bootc

## Security Features

- DNS over TLS with Cloudflare/Quad9
- DNSSEC enabled
- MAC address randomization
- Container signing with cosign
- Immutable OS with atomic updates