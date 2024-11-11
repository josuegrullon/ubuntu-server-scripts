#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to prompt for confirmation
confirm() {
    read -p "Are you sure you want to $1? (y/n): " choice
    case "$choice" in 
        y|Y ) return 0;;
        * ) return 1;;
    esac
}

echo -e "${RED}WARNING: This script will remove Perfex CRM and its dependencies${NC}"
echo -e "${YELLOW}The following will be removed:${NC}"
echo "1. Nginx configuration and web files"
echo "2. PHP 8.1 and all extensions"
echo "3. MariaDB (including all databases)"
echo "4. phpMyAdmin"
echo "5. SSL certificates"
echo "6. All related configuration files"

if ! confirm "proceed with uninstallation"; then
    echo -e "${YELLOW}Uninstallation cancelled${NC}"
    exit 0
fi

# Get domain name for SSL certificate removal
read -p "Enter the domain name used in the installation: " DOMAIN_NAME

echo -e "\n${YELLOW}Starting uninstallation process...${NC}"

# Step 1: Backup database if requested
if confirm "backup the database before removal"; then
    echo -e "${YELLOW}Creating database backup...${NC}"
    BACKUP_FILE="perfex_backup_$(date +%Y%m%d_%H%M%S).sql"
    sudo mysqldump perfex > "$BACKUP_FILE" 2>/dev/null || echo "No database to backup"
    if [ -f "$BACKUP_FILE" ]; then
        echo -e "${GREEN}Database backed up to $BACKUP_FILE${NC}"
    fi
fi

# Step 2: Remove SSL certificates
if [ ! -z "$DOMAIN_NAME" ]; then
    echo -e "${YELLOW}Removing SSL certificates...${NC}"
    sudo certbot delete --cert-name $DOMAIN_NAME --non-interactive || true
fi

# Step 3: Remove Nginx configurations
echo -e "${YELLOW}Removing Nginx configurations...${NC}"
sudo rm -f /etc/nginx/sites-enabled/perfex
sudo rm -f /etc/nginx/sites-available/perfex
sudo systemctl restart nginx || true

# Step 4: Remove web files
echo -e "${YELLOW}Removing web files...${NC}"
if confirm "remove all files in /var/www/perfex"; then
    sudo rm -rf /var/www/perfex
fi

# Step 5: Remove Database and User
if confirm "remove the MariaDB database and user"; then
    echo -e "${YELLOW}Removing database and user...${NC}"
    sudo mysql -e "DROP DATABASE IF EXISTS perfex;"
    sudo mysql -e "DROP USER IF EXISTS 'perfexuser'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
fi

# Step 6: Remove Software Packages
if confirm "remove installed software packages"; then
    echo -e "${YELLOW}Removing software packages...${NC}"
    
    # Remove PHP and extensions
    sudo apt-get remove --purge -y php8.1-fpm php8.1-common php8.1-mysql \
        php8.1-xml php8.1-xmlrpc php8.1-curl php8.1-gd \
        php8.1-imagick php8.1-cli php8.1-dev php8.1-imap \
        php8.1-mbstring php8.1-opcache php8.1-soap \
        php8.1-zip php8.1-intl php8.1-bcmath

    # Remove MariaDB
    sudo apt-get remove --purge -y mariadb-server mariadb-client

    # Remove phpMyAdmin
    sudo apt-get remove --purge -y phpmyadmin

    # Remove Nginx if requested
    if confirm "remove Nginx"; then
        sudo apt-get remove --purge -y nginx nginx-common
    fi

    # Remove Certbot
    sudo apt-get remove --purge -y certbot python3-certbot-nginx
fi

# Step 7: Remove PHP repository
if confirm "remove PHP repository"; then
    echo -e "${YELLOW}Removing PHP repository...${NC}"
    sudo add-apt-repository --remove ppa:ondrej/php -y
fi

# Step 8: Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
sudo apt-get autoremove -y
sudo apt-get autoclean

# Step 9: Remove installation markers
echo -e "${YELLOW}Removing installation markers...${NC}"
sudo rm -f /tmp/perfex_install_*

# Step 10: Remove configuration files
if confirm "remove all configuration files"; then
    echo -e "${YELLOW}Removing configuration files...${NC}"
    sudo rm -rf /etc/php/8.1
    sudo rm -rf /etc/mysql
    sudo rm -rf /etc/phpmyadmin
fi

echo -e "\n${GREEN}Uninstallation completed!${NC}"
if [ -f "$BACKUP_FILE" ]; then
    echo -e "${YELLOW}Your database backup is stored in: $BACKUP_FILE${NC}"
fi

# Final cleanup suggestion
echo -e "\n${YELLOW}Additional manual cleanup you might want to perform:${NC}"
echo "1. Remove any remaining files in /var/www if no longer needed"
echo "2. Check for any remaining configuration files in /etc"
echo "3. Remove any cron jobs that were set up for Perfex"
echo "4. Remove any backup files if no longer needed"

# Reset the system services
echo -e "\n${YELLOW}Restarting services...${NC}"
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo -e "\n${GREEN}System restored to pre-installation state!${NC}"