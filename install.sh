#!/bin/bash

set -e

REPO="8xu/envswitch"
BINARY_NAME="envswitch"
VERSION="v1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

banner() {
    echo -e "${BLUE}"
    echo "  █████╗ ██╗      ██████╗  ██████╗ ██████╗ "
    echo " ██╔══██╗██║     ██╔═══██╗██╔═══██╗██╔══██╗"
    echo " ███████║██║     ██║   ██║██║   ██║██████╔╝"
    echo " ██╔══██║██║     ██║   ██║██║   ██║██╔══██╗"
    echo " ██║  ██║███████╗╚██████╔╝╚██████╔╝██║  ██║"
    echo " ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝"
    echo -e "${NC}"
}

detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux";;
        Darwin*)  echo "darwin";;
        *)        echo "unknown";;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64)   echo "amd64";;
        aarch64)  echo "arm64";;
        arm64)    echo "arm64";;
        armv7*)   echo "armv7";;
        *)        echo "amd64";;
    esac
}

check_deps() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required but not installed.${NC}"
        exit 1
    fi
}

get_version() {
    curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4
}

install() {
    banner
    
    check_deps
    
    echo -e "${YELLOW}Detecting system...${NC}"
    os=$(detect_os)
    arch=$(detect_arch)
    
    echo -e "${YELLOW}OS: ${os}${NC}"
    echo -e "${YELLOW}Architecture: ${arch}${NC}"
    
    echo -e "${YELLOW}Fetching latest version...${NC}"
    version=$(get_version)
    echo -e "${YELLOW}Version: ${version}${NC}"
    
    url="https://github.com/$REPO/releases/download/${version}/${BINARY_NAME}-${os}-${arch}"
    
    echo -e "${YELLOW}Downloading...${NC}"
    tmp_dir=$(mktemp -d)
    
    if ! curl -fsSL -o "$tmp_dir/$BINARY_NAME" "$url"; then
        echo -e "${RED}Error: Failed to download binary for ${os}-${arch}${NC}"
        echo -e "${YELLOW}Supported platforms: darwin-amd64, darwin-arm64, linux-amd64${NC}"
        rm -rf $tmp_dir
        exit 1
    fi
    
    chmod +x "$tmp_dir/$BINARY_NAME"
    
    echo -e "${YELLOW}Installing...${NC}"
    
    if [ -w /usr/local/bin ]; then
        sudo mv "$tmp_dir/$BINARY_NAME" /usr/local/bin/$BINARY_NAME
    else
        mkdir -p "$HOME/.local/bin"
        mv "$tmp_dir/$BINARY_NAME" "$HOME/.local/bin/$BINARY_NAME"
        echo -e "${YELLOW}Note: Added $HOME/.local/bin to PATH in your shell profile${NC}"
    fi
    
    rm -rf $tmp_dir
    
    echo -e "${GREEN}✓ Installed envswitch ${version}${NC}"
    echo ""
    echo -e "${BLUE}Quick start:${NC}"
    echo "  envswitch --list"
    echo "  envswitch staging"
    echo ""
    echo -e "${BLUE}For help:${NC}"
    echo "  envswitch --help"
}

uninstall() {
    banner
    echo -e "${YELLOW}Uninstalling envswitch...${NC}"
    
    if [ -f /usr/local/bin/envswitch ]; then
        sudo rm /usr/local/bin/envswitch
        echo -e "${GREEN}✓ Removed from /usr/local/bin${NC}"
    elif [ -f "$HOME/.local/bin/envswitch" ]; then
        rm "$HOME/.local/bin/envswitch"
        echo -e "${GREEN}✓ Removed from ~/.local/bin${NC}"
    else
        echo -e "${YELLOW}envswitch not found in standard locations${NC}"
    fi
}

update() {
    banner
    echo -e "${YELLOW}Checking for updates...${NC}"
    
    current=$(envswitch --version 2>/dev/null || echo "unknown")
    latest=$(get_version)
    
    if [ "$current" = "$latest" ]; then
        echo -e "${GREEN}Already up to date!${NC}"
    else
        echo -e "${YELLOW}Updating from $current to $latest...${NC}"
        install
    fi
}

case "${1:-install}" in
    install)    install ;;
    uninstall)  uninstall ;;
    update)     update ;;
    *)          echo "Usage: $0 {install|uninstall|update}" ;;
esac
