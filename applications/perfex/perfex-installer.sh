#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a step was already completed
check_step() {
    if [ -f "/tmp/perfex_install_$1" ]; then
        return 0 # Step was completed
    else
        return 1 # Step was not completed
    fi
}

# Function to mark a step as completed
mark_step_completed() {
    touch "/tmp/perfex_install_$1"
}

# Function to prompt for continuation
prompt_continue() {
    read -p "Continue with this step? (y/n): " choice
    case "$choice" in 
        y|Y ) return 0;;
        * ) return 1;;
    esac
}

# Get domain name
read -p "Enter your domain name (e.g., example.com): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    echo -e "${RED}Domain name is required${NC}"
    exit 1
fi

echo -e "${YELLOW}Installing Perfex CRM environment for domain: $DOMAIN_NAME${NC}"

# Step 1: System Update
if ! check_step "system_update"; then
    echo -e "${YELLOW}Step 1: Updating system packages${NC}"
    if prompt_continue; then
        sudo apt update && sudo apt upgrade -y
        mark_step_completed "system_update"
        echo -e "${GREEN}System update completed${NC}"
    fi
else
    echo -e "${GREEN}System already updated${NC}"
fi

# Step 2: Install Nginx
if ! check_step "nginx"; then
    echo -e "${YELLOW}Step 2: Installing Nginx${NC}"
    if prompt_continue; then
        sudo apt install -y nginx
        mark_step_completed "nginx"
        echo -e "${GREEN}Nginx installation completed${NC}"
    fi
else
    echo -e "${GREEN}Nginx already installed${NC}"
fi

# Step 3: Install PHP and extensions
if ! check_step "php"; then
    echo -e "${YELLOW}Step 3: Installing PHP and extensions${NC}"
    if prompt_continue; then
        sudo add-apt-repository ppa:ondrej/php -y
        sudo apt update
        sudo apt install -y php8.1-fpm php8.1-common php8.1-mysql \
            php8.1-xml php8.1-xmlrpc php8.1-curl php8.1-gd \
            php8.1-imagick php8.1-cli php8.1-dev php8.1-imap \
            php8.1-mbstring php8.1-opcache php8.1-soap \
            php8.1-zip php8.1-intl php8.1-bcmath
        mark_step_completed "php"
        echo -e "${GREEN}PHP installation completed${NC}"
    fi
else
    echo -e "${GREEN}PHP already installed${NC}"
fi

# Step 4: Install MariaDB
if ! check_step "mariadb"; then
    echo -e "${YELLOW}Step 4: Installing MariaDB${NC}"
    if prompt_continue; then
        sudo apt install -y mariadb-server mariadb-client
        mark_step_completed "mariadb"
        echo -e "${GREEN}MariaDB installation completed${NC}"
    fi
else
    echo -e "${GREEN}MariaDB already installed${NC}"
fi

# Step 5: Install phpMyAdmin
if ! check_step "phpmyadmin"; then
    echo -e "${YELLOW}Step 5: Installing phpMyAdmin${NC}"
    if prompt_continue; then
        sudo apt install -y phpmyadmin
        mark_step_completed "phpmyadmin"
        echo -e "${GREEN}phpMyAdmin installation completed${NC}"
    fi
else
    echo -e "${GREEN}phpMyAdmin already installed${NC}"
fi

# Step 6: Configure Nginx
if ! check_step "nginx_config"; then
    echo -e "${YELLOW}Step 6: Configuring Nginx${NC}"
    if prompt_continue; then
        # Remove default nginx config if exists
        sudo rm -f /etc/nginx/sites-enabled/default

        # Create Nginx configuration
        sudo tee /etc/nginx/sites-available/perfex.conf << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    root /var/www/perfex;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
        sudo ln -sf /etc/nginx/sites-available/perfex.conf /etc/nginx/sites-enabled/
        mark_step_completed "nginx_config"
        echo -e "${GREEN}Nginx configuration completed${NC}"
    fi
else
    echo -e "${GREEN}Nginx already configured${NC}"
fi

# Step 7: Install Certbot and configure SSL
if ! check_step "ssl"; then
    echo -e "${YELLOW}Step 7: Installing Certbot and configuring SSL${NC}"
    if prompt_continue; then
        # Install Certbot
        sudo apt install -y certbot python3-certbot-nginx
        
        # Obtain and install SSL certificate
        sudo certbot --nginx -d $DOMAIN_NAME --non-interactive --agree-tos --email webmaster@$DOMAIN_NAME
        mark_step_completed "ssl"
        echo -e "${GREEN}SSL configuration completed${NC}"
    fi
else
    echo -e "${GREEN}SSL already configured${NC}"
fi

# Step 8: Create web root and set permissions
if ! check_step "webroot"; then
    echo -e "${YELLOW}Step 8: Creating web root and setting permissions${NC}"
    if prompt_continue; then
        sudo mkdir -p /var/www/perfex
        sudo chown -R www-data:www-data /var/www/perfex
        sudo chmod -R 755 /var/www/perfex
        mark_step_completed "webroot"
        echo -e "${GREEN}Web root setup completed${NC}"
    fi
else
    echo -e "${GREEN}Web root already setup${NC}"
fi

# Step 9: Restart services
echo -e "${YELLOW}Step 9: Restarting services${NC}"
if prompt_continue; then
    sudo systemctl restart nginx
    sudo systemctl restart php8.1-fpm
    sudo systemctl restart mariadb
    echo -e "${GREEN}Services restarted${NC}"
fi

# Final steps and information
echo -e "\n${GREEN}Installation process completed!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Create a MariaDB database and user for Perfex using these commands:"
echo -e "${GREEN}"
echo "sudo mysql -e 'CREATE DATABASE perfex;'"
echo "sudo mysql -e \"CREATE USER 'perfexuser'@'localhost' IDENTIFIED BY 'your_password';\""
echo "sudo mysql -e \"GRANT ALL PRIVILEGES ON perfex.* TO 'perfexuser'@'localhost';\""
echo "sudo mysql -e 'FLUSH PRIVILEGES;'"
echo -e "${NC}"
echo "2. Download and extract Perfex CRM to /var/www/perfex"
echo "3. Access your site at: https://$DOMAIN_NAME"
echo "4. Access phpMyAdmin at: https://$DOMAIN_NAME/phpmyadmin"

# Optional database setup
read -p "Would you like to set up the database now? (y/n): " setup_db
if [[ $setup_db =~ ^[Yy]$ ]]; then
    read -p "Enter desired database password for perfexuser: " db_password
    sudo mysql -e "CREATE DATABASE perfex;"
    sudo mysql -e "CREATE USER 'perfexuser'@'localhost' IDENTIFIED BY '$db_password';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON perfex.* TO 'perfexuser'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    echo -e "${GREEN}Database setup completed!${NC}"
fi

echo -e "\n${GREEN}Installation completed successfully!${NC}"