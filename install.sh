#!/bin/bash

set -e

REPO="8xu/envswitch"
BINARY_NAME="envswitch"

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
        *)        echo "amd64";;
    esac
}

install() {
    os=$(detect_os)
    arch=$(detect_arch)
    version=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep -o '"tag_name"' | cut -d: -f2 | tr -d '" ')
    
    url="https://github.com/$REPO/releases/download/${version}/${BINARY_NAME}-${os}-${arch}"
    
    tmp_dir=$(mktemp -d)
    curl -fsSL -o "$tmp_dir/$BINARY_NAME" "$url"
    chmod +x "$tmp_dir/$BINARY_NAME"
    
    if [ -w /usr/local/bin ]; then
        sudo mv "$tmp_dir/$BINARY_NAME" /usr/local/bin/$BINARY_NAME
    else
        mkdir -p "$HOME/.local/bin"
        mv "$tmp_dir/$BINARY_NAME" "$HOME/.local/bin/$BINARY_NAME"
        echo "Add to PATH: export PATH=\$HOME/.local/bin:\$PATH"
    fi
    
    rm -rf $tmp_dir
    echo "Installed envswitch $version"
}

install
