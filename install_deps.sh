#!/usr/bin/env bash

set -euo pipefail

# Define versions
PROTOC_VERSION="27.2"
PROTOLINT_VERSION="0.50.0"

# Function to get the appropriate download URL based on OS and architecture
get_download_url() {
    local tool=$1
    local os=$(uname -s)
    local arch=$(uname -m)

    case "$os" in
        Linux)
            protoc_os="linux"
            protolint_os="Linux"
            ;;
        Darwin)
            protoc_os="osx"
            protolint_os="darwin"
            ;;
        *)
            echo "Unsupported OS: $os" >&2
            return 1
            ;;
    esac

    case "$arch" in
        x86_64)
            protoc_arch="x86_64"
            protolint_arch="amd64"
            ;;
        arm64|aarch64)
            protoc_arch="aarch_64"
            protolint_arch="arm64"
            ;;
        *)
            echo "Unsupported architecture: $arch" >&2
            return 1
            ;;
    esac

    if [ "$tool" = "protoc" ]; then
        if [ "$os" = "Darwin" ]; then
            echo "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-osx-universal_binary.zip"
        else
            echo "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-${protoc_os}-${protoc_arch}.zip"
        fi
    elif [ "$tool" = "protolint" ]; then
        echo "https://github.com/yoheimuta/protolint/releases/download/v${PROTOLINT_VERSION}/protolint_${PROTOLINT_VERSION}_${protolint_os}_${protolint_arch}.tar.gz"
    else
        echo "Unknown tool: $tool" >&2
        return 1
    fi
}

# Function to download and install a tool
install_tool() {
    local tool=$1
    local url
    url=$(get_download_url "$tool") || return 1

    echo "Installing $tool"
    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    if ! wget -q "$url"; then
        echo "Failed to download $tool" >&2
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 1
    fi

    local filename
    filename=$(basename "$url")

    case "$filename" in
        *.zip)
            unzip -q "$filename"
            ;;
        *.tar.gz)
            tar -xzf "$filename"
            ;;
        *)
            echo "Unsupported file format: $filename" >&2
            cd - > /dev/null
            rm -rf "$temp_dir"
            return 1
            ;;
    esac

    if [ "$tool" = "protoc" ]; then
        sudo mv bin/protoc /usr/local/bin/protoc
    elif [ "$tool" = "protolint" ]; then
        sudo mv protolint /usr/local/bin/protolint
    fi

    cd - > /dev/null
    rm -rf "$temp_dir"
    echo "$tool installed successfully"
}


function verify() {
    if [ $? -ne 0 ]; then
        echo "Failed to install $1" >&2
        exit 1
    fi
}
# Main execution
main() {
    install_tool "protoc" || exit 1
    install_tool "protolint" || exit 1

    verify "protoc"
    verify "protolint"

    echo "Installation completed successfully!"
}

main