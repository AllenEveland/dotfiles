#!/bin/bash

# ─────────────────────────────────────────
#  Setup Script – Hyprland Environment
# ─────────────────────────────────────────

set -e

# ── Colors ───────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Package list ─────────────────────────
PACKAGES=(
    hyprland
    hyprlock
    hypridle
    waybar
    rofi
    swaync
    awww
    xdg-desktop-portal-hyprland
    alacritty
    ttf-fira-code
    ttf-firacode-nerd
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    btop
    nautilus
    grim
    slurp
)

# ─────────────────────────────────────────
#  Function: Install packages
# ─────────────────────────────────────────
install_packages() {
    echo -e "\n${CYAN}${BOLD}[1/3] Installing packages...${RESET}"
    echo -e "${YELLOW}Packages to be installed:${RESET}"
    for pkg in "${PACKAGES[@]}"; do
        echo -e "  ${GREEN}+${RESET} $pkg"
    done
    echo ""

    sudo pacman -S --needed "${PACKAGES[@]}"

    echo -e "\n${GREEN}✔ Package installation complete.${RESET}"
}

# ─────────────────────────────────────────
#  Ask user if they have backed up
# ─────────────────────────────────────────
confirm_backup() {
    echo -e "\n${CYAN}${BOLD}[2/3] Backup check...${RESET}"
    echo -e "${YELLOW}⚠  This script will overwrite files in ${BOLD}~/.config/${RESET}${YELLOW} and your personal config directory.${RESET}"
    echo -ne "${BOLD}Have you backed up your data? [Y/n]: ${RESET}"
    read -r answer

    case "$answer" in
        [Yy] | "")
            echo -e "${GREEN}✔ Continuing...${RESET}"
            ;;
        [Nn])
            echo -e "\n${RED}Terminated by user${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid input. Exiting for safety.${RESET}"
            echo -e "${RED}Terminated by user${RESET}"
            exit 0
            ;;
    esac
}

# ─────────────────────────────────────────
#  Function: Copy configs
# ─────────────────────────────────────────
copy_configs() {
    echo -e "\n${CYAN}${BOLD}[3/3] Copying config files...${RESET}"

    # ── Copy ./config/* → ~/.config/ ─────
    if [ -d "./config" ]; then
        echo -e "${YELLOW}→ Copying ./config/* to ~/.config/${RESET}"
        mkdir -p "$HOME/.config"
        cp -r ./config/* "$HOME/.config/"
        echo -e "${GREEN}  ✔ Done.${RESET}"
    else
        echo -e "${RED}  ✘ Directory ./config not found – skipping.${RESET}"
    fi

    # ── Copy ./allenconf/* → ~/<username>conf/ ──
    if [ -d "./allenconf" ]; then
        USERNAME=$(whoami)
        DEST_DIR="$HOME/${USERNAME}conf"

        echo -e "${YELLOW}→ Copying ./allenconf/* to ${DEST_DIR}/${RESET}"
        mkdir -p "$DEST_DIR"
        cp -r ./allenconf/* "$DEST_DIR/"
        echo -e "${GREEN}  ✔ Done – destination: ${BOLD}${DEST_DIR}${RESET}"
    else
        echo -e "${RED}  ✘ Directory ./allenconf not found – skipping.${RESET}"
    fi
}

# ─────────────────────────────────────────
#  Main
# ─────────────────────────────────────────
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════╗"
echo "║   Hyprland Environment Setup Script  ║"
echo "╚══════════════════════════════════════╝"
echo -e "${RESET}"

install_packages
confirm_backup
copy_configs

echo -e "\n${GREEN}${BOLD}✔ Setup complete!${RESET}\n"