#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to backup current PHP configuration
backup_php_config() {
    local php_version=$1
    echo -e "${YELLOW}Backing up PHP $php_version configuration...${NC}"
    
    if [ -d "/etc/php/$php_version" ]; then
        backup_dir="/root/php_backup_$(date +%Y%m%d_%H%M%S)"
        sudo mkdir -p "$backup_dir"
        sudo cp -r "/etc/php/$php_version" "$backup_dir/"
        echo -e "${GREEN}PHP configuration backed up to $backup_dir${NC}"
    else
        echo -e "${YELLOW}No configuration found for PHP $php_version${NC}"
    fi
}

# Function to get current PHP version
get_current_php_version() {
    if command_exists php; then
        php -v | grep -oP "PHP \K[0-9]+\.[0-9]+" | head -n1
    else
        echo "none"
    fi
}

# Function to get all installed PHP versions
get_installed_php_versions() {
    ls /etc/php/ 2>/dev/null || echo "none"
}

echo -e "${YELLOW}PHP Upgrade Script${NC}"
echo "==============================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# Add PHP repository if not already added
if ! grep -q "^deb .*ppa:ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo -e "${YELLOW}Adding PHP repository...${NC}"
    sudo add-apt-repository ppa:ondrej/php -y
fi

# Update package list
echo -e "${YELLOW}Updating package list...${NC}"
sudo apt update

# Get current PHP version
CURRENT_VERSION=$(get_current_php_version)
echo -e "Current PHP version: ${GREEN}$CURRENT_VERSION${NC}"

# Get all installed PHP versions
echo -e "${YELLOW}Installed PHP versions:${NC}"
get_installed_php_versions

# Get latest available PHP version
LATEST_VERSION=$(apt-cache search php | grep -oP "^php\d+\.\d+" | sort -V | tail -n1 | grep -oP "\d+\.\d+")
echo -e "Latest available PHP version: ${GREEN}$LATEST_VERSION${NC}"

# Ask for confirmation
read -p "Do you want to upgrade to PHP $LATEST_VERSION? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Upgrade cancelled${NC}"
    exit 1
fi

# Backup current PHP configuration
if [ "$CURRENT_VERSION" != "none" ]; then
    backup_php_config "$CURRENT_VERSION"
fi

# List of common PHP modules
PHP_MODULES=(
    cli
    fpm
    common
    mysql
    xml
    xmlrpc
    curl
    gd
    imagick
    dev
    imap
    mbstring
    opcache
    soap
    zip
    intl
    bcmath
)

echo -e "${YELLOW}Installing PHP $LATEST_VERSION and modules...${NC}"

# Install new PHP version and modules
for module in "${PHP_MODULES[@]}"; do
    echo -e "${YELLOW}Installing php$LATEST_VERSION-$module...${NC}"
    sudo apt install -y php$LATEST_VERSION-$module
done

# Update PHP alternatives
echo -e "${YELLOW}Updating PHP alternatives...${NC}"
sudo update-alternatives --set php /usr/bin/php$LATEST_VERSION
sudo update-alternatives --set phar /usr/bin/phar$LATEST_VERSION
sudo update-alternatives --set phar.phar /usr/bin/phar.phar$LATEST_VERSION

# Disable old PHP-FPM version and enable new one
if [ "$CURRENT_VERSION" != "none" ]; then
    echo -e "${YELLOW}Disabling PHP $CURRENT_VERSION FPM...${NC}"
    sudo systemctl disable php$CURRENT_VERSION-fpm
    sudo systemctl stop php$CURRENT_VERSION-fpm
fi

echo -e "${YELLOW}Enabling PHP $LATEST_VERSION FPM...${NC}"
sudo systemctl enable php$LATEST_VERSION-fpm
sudo systemctl start php$LATEST_VERSION-fpm

# Configure PHP-FPM for Nginx
if command_exists nginx; then
    echo -e "${YELLOW}Updating Nginx PHP-FPM configuration...${NC}"
    sudo sed -i "s/php$CURRENT_VERSION-fpm/php$LATEST_VERSION-fpm/g" /etc/nginx/sites-available/*
    sudo systemctl restart nginx
fi

# Cleanup old PHP version if requested
read -p "Do you want to remove PHP $CURRENT_VERSION? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Removing PHP $CURRENT_VERSION...${NC}"
    for module in "${PHP_MODULES[@]}"; do
        sudo apt remove -y php$CURRENT_VERSION-$module
    done
    sudo apt autoremove -y
fi

# Verify new PHP version
NEW_VERSION=$(php -v | grep -oP "PHP \K[0-9]+\.[0-9]+" | head -n1)
if [ "$NEW_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "${GREEN}Successfully upgraded to PHP $LATEST_VERSION${NC}"
    
    # Show PHP-FPM status
    echo -e "\n${YELLOW}PHP-FPM Status:${NC}"
    sudo systemctl status php$LATEST_VERSION-fpm | grep "Active:"
    
    # Show memory limit and max execution time
    echo -e "\n${YELLOW}PHP Configuration:${NC}"
    echo "Memory Limit: $(php -r 'echo ini_get("memory_limit");')"
    echo "Max Execution Time: $(php -r 'echo ini_get("max_execution_time");')"
    
    echo -e "\n${GREEN}Upgrade completed successfully!${NC}"
    echo -e "Backup location: $backup_dir"
else
    echo -e "${RED}Upgrade seems to have failed. Please check the logs.${NC}"
fi

# Optional: Display common PHP configurations that might need adjustment
echo -e "\n${YELLOW}Consider checking these PHP configurations:${NC}"
echo "1. php.ini location: /etc/php/$LATEST_VERSION/fpm/php.ini"
echo "2. PHP-FPM pool configuration: /etc/php/$LATEST_VERSION/fpm/pool.d/www.conf"
echo "3. Nginx configuration if using PHP-FPM"

echo -e "\n${YELLOW}To apply any changes, restart PHP-FPM:${NC}"
echo "sudo systemctl restart php$LATEST_VERSION-fpm"