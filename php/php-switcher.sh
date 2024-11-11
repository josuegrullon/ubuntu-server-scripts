#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to list installed PHP versions
list_installed_php() {
    echo -e "${YELLOW}Installed PHP versions:${NC}"
    ls /etc/php/ 2>/dev/null | grep -E '^[0-9]+\.[0-9]+$' || echo "No PHP versions found"
}

# Function to switch PHP version for CLI
switch_php_cli() {
    local version=$1
    echo -e "${YELLOW}Switching CLI version to PHP $version...${NC}"
    sudo update-alternatives --set php /usr/bin/php$version
    sudo update-alternatives --set phar /usr/bin/phar$version
    sudo update-alternatives --set phar.phar /usr/bin/phar.phar$version
}

# Function to switch PHP-FPM for Nginx
switch_php_fpm() {
    local version=$1
    local old_version=$2
    
    # Stop old PHP-FPM
    if [ ! -z "$old_version" ]; then
        sudo systemctl stop php$old_version-fpm
        sudo systemctl disable php$old_version-fpm
    fi

    # Start new PHP-FPM
    sudo systemctl start php$version-fpm
    sudo systemctl enable php$version-fpm

    # Update Nginx configuration if it exists
    if [ -d "/etc/nginx/sites-available" ]; then
        echo -e "${YELLOW}Updating Nginx configurations...${NC}"
        sudo find /etc/nginx/sites-available -type f -exec sed -i "s/php[0-9]\.[0-9]-fpm/php$version-fpm/g" {} \;
        sudo systemctl reload nginx
    fi
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Get current PHP version
current_version=$(php -v 2>/dev/null | grep -oP "PHP \K[0-9]+\.[0-9]+" | head -n1)
echo -e "${YELLOW}Current PHP version: $current_version${NC}"

# List installed versions
list_installed_php

# Get available versions
echo -e "\n${YELLOW}Available PHP versions to install:${NC}"
apt-cache search php | grep -oP "^php\d+\.\d+" | sort -u

# Prompt for version
read -p "Enter the PHP version to switch to (e.g., 8.1): " version

# Validate input
if [[ ! $version =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Invalid version format. Please use format like '8.1'${NC}"
    exit 1
fi

# Check if version is installed
if [ ! -d "/etc/php/$version" ]; then
    echo -e "${YELLOW}PHP $version is not installed. Would you like to install it? (y/n)${NC}"
    read -r install_new
    if [[ $install_new =~ ^[Yy]$ ]]; then
        # Install new PHP version
        sudo apt install -y php$version-fpm php$version-cli php$version-common \
            php$version-mysql php$version-xml php$version-curl php$version-gd \
            php$version-mbstring php$version-bcmath php$version-zip
    else
        echo -e "${RED}Aborting switch. Please install PHP $version first${NC}"
        exit 1
    fi
fi

# Switch PHP version
switch_php_cli $version
switch_php_fpm $version $current_version

# Verify the switch
new_version=$(php -v | grep -oP "PHP \K[0-9]+\.[0-9]+" | head -n1)
if [ "$new_version" = "$version" ]; then
    echo -e "${GREEN}Successfully switched to PHP $version${NC}"
    php -v
    echo -e "\n${YELLOW}PHP-FPM status:${NC}"
    systemctl status php$version-fpm --no-pager | grep "Active:"
else
    echo -e "${RED}Failed to switch PHP version${NC}"
fi

# Additional info
echo -e "\n${YELLOW}To verify the switch:${NC}"
echo "1. Check PHP CLI version: php -v"
echo "2. Check PHP-FPM status: systemctl status php$version-fpm"
echo "3. Check Nginx configuration: nginx -t"