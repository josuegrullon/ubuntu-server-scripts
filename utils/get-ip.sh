#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking your public IP from multiple sources...${NC}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get IP with a specific method
get_ip() {
    local url=$1
    local method=$2
    echo -e "${YELLOW}Trying $method...${NC}"
    if command_exists curl; then
        ip=$(curl -s "$url")
        if [ $? -eq 0 ] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${GREEN}Your public IP (via $method): $ip${NC}"
            return 0
        fi
    elif command_exists wget; then
        ip=$(wget -qO- "$url")
        if [ $? -eq 0 ] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "${GREEN}Your public IP (via $method): $ip${NC}"
            return 0
        fi
    fi
    echo -e "${RED}Failed to get IP from $method${NC}"
    return 1
}

# Try different IP services
services=(
    "https://api.ipify.org ipify.org"
    "https://ifconfig.me/ip ifconfig.me"
    "https://checkip.amazonaws.com AWS"
    "https://icanhazip.com icanhazip.com"
    "https://ident.me ident.me"
    "https://ipecho.net/plain ipecho.net"
)

# Check if curl or wget is installed
if ! command_exists curl && ! command_exists wget; then
    echo -e "${RED}Error: Neither curl nor wget is installed. Installing curl...${NC}"
    sudo apt-get update && sudo apt-get install -y curl
fi

# Try each service
success=false
for service in "${services[@]}"; do
    read -r url method <<< "$service"
    if get_ip "$url" "$method"; then
        success=true
        break
    fi
done

if ! $success; then
    echo -e "${RED}Failed to get public IP from all methods${NC}"
    exit 1
fi

# Optional: Show local IPs as well
echo -e "\n${YELLOW}Local IP Addresses:${NC}"
ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1 | while read -r line; do
    echo -e "${GREEN}$line${NC}"
done