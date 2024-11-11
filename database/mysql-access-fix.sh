#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate password strength
validate_password() {
    local password=$1
    if [[ ${#password} -lt 8 ]]; then
        echo -e "${RED}Password must be at least 8 characters long${NC}"
        return 1
    fi
    if ! [[ $password =~ [A-Z] ]]; then
        echo -e "${RED}Password must contain at least one uppercase letter${NC}"
        return 1
    fi
    if ! [[ $password =~ [a-z] ]]; then
        echo -e "${RED}Password must contain at least one lowercase letter${NC}"
        return 1
    fi
    if ! [[ $password =~ [0-9] ]]; then
        echo -e "${RED}Password must contain at least one number${NC}"
        return 1
    fi
    if ! [[ $password =~ ['!@#$%^&*()_+'] ]]; then
        echo -e "${RED}Password must contain at least one special character${NC}"
        return 1
    fi
    return 0
}

# Get and validate new password
while true; do
    echo -e "${YELLOW}Enter new MariaDB root password:${NC}"
    read -s password
    echo
    
    echo -e "${YELLOW}Confirm password:${NC}"
    read -s password_confirm
    echo

    if [ "$password" != "$password_confirm" ]; then
        echo -e "${RED}Passwords do not match. Please try again.${NC}"
        continue
    fi

    if validate_password "$password"; then
        break
    fi
done

echo -e "${YELLOW}Fixing MariaDB root access...${NC}"

# Stop MariaDB service
sudo systemctl stop mariadb
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to stop MariaDB service${NC}"
    exit 1
fi

# Start MariaDB in safe mode
echo -e "${YELLOW}Starting MariaDB in safe mode...${NC}"
sudo mysqld_safe --skip-grant-tables --skip-networking &
sleep 5

# Reset root password and privileges
echo -e "${YELLOW}Resetting root password...${NC}"
sudo mysql << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$password';
FLUSH PRIVILEGES;
EOF

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to reset password${NC}"
    sudo pkill mysqld
    sudo systemctl start mariadb
    exit 1
fi

# Stop MariaDB safe mode
echo -e "${YELLOW}Stopping safe mode...${NC}"
sudo pkill mysqld
sleep 5

# Start MariaDB normally
echo -e "${YELLOW}Starting MariaDB normally...${NC}"
sudo systemctl start mariadb
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to start MariaDB service${NC}"
    exit 1
fi

# Test the new password
echo -e "${YELLOW}Testing new password...${NC}"
if mysql -u root -p"$password" -e "SELECT 'Connection successful!' AS Result;" &>/dev/null; then
    echo -e "${GREEN}Password successfully reset!${NC}"
    echo -e "\nYou can now connect using: ${YELLOW}mysql -u root -p${NC}"
    echo -e "Your new password has been set and verified."
    
    # Ask about running mysql_secure_installation
    echo -e "\n${YELLOW}Would you like to run mysql_secure_installation to improve security? (y/n)${NC}"
    read -r run_secure
    if [[ $run_secure =~ ^[Yy]$ ]]; then
        sudo mysql_secure_installation
    fi
else
    echo -e "${RED}Failed to verify new password. Please try running the script again.${NC}"
fi