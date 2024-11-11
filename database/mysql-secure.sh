#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Function to execute MySQL commands
execute_mysql_command() {
    local command=$1
    local password=$2
    if [ -z "$password" ]; then
        mysql -e "$command"
    else
        mysql -p"$password" -e "$command"
    fi
}

# Clear screen and show banner
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}             MySQL/MariaDB Security Configuration              ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo

# Check if MySQL/MariaDB is installed
if ! command -v mysql >/dev/null 2>&1; then
    echo -e "${RED}MySQL/MariaDB is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if the service is running
if ! systemctl is-active --quiet mysql; then
    echo -e "${YELLOW}MySQL/MariaDB service is not running. Starting it now...${NC}"
    sudo systemctl start mysql
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start MySQL/MariaDB service. Please check the logs.${NC}"
        exit 1
    fi
fi

# Initial Configuration Steps
echo -e "${YELLOW}This script will help you secure your MySQL/MariaDB installation.${NC}"
echo -e "${YELLOW}The following steps will be performed:${NC}"
echo "1. Set root password"
echo "2. Remove anonymous users"
echo "3. Disable remote root login"
echo "4. Remove test database"
echo "5. Reload privilege tables"
echo "6. Configure password validation policy"
echo

# Step 1: Root Password
echo -e "${BLUE}Step 1: Setting Root Password${NC}"
echo -e "${YELLOW}Would you like to change the root password? (y/n)${NC}"
read -r change_root_pass
if [[ "$change_root_pass" =~ ^[Yy]$ ]]; then
    while true; do
        echo -e "${YELLOW}Enter new root password:${NC}"
        read -s root_pass
        echo
        echo -e "${YELLOW}Confirm root password:${NC}"
        read -s root_pass_confirm
        echo

        if [ "$root_pass" != "$root_pass_confirm" ]; then
            echo -e "${RED}Passwords do not match. Please try again.${NC}"
            continue
        fi

        if validate_password "$root_pass"; then
            # Try to set root password
            if mysqladmin -u root password "$root_pass" 2>/dev/null || mysqladmin -u root -p password "$root_pass"; then
                echo -e "${GREEN}Root password successfully updated${NC}"
                break
            else
                echo -e "${RED}Failed to set root password. Please check your current root password.${NC}"
                exit 1
            fi
        fi
    done
fi

# Step 2: Anonymous Users
echo -e "\n${BLUE}Step 2: Remove Anonymous Users${NC}"
echo -e "${YELLOW}Would you like to remove anonymous users? (y/n)${NC}"
read -r remove_anonymous
if [[ "$remove_anonymous" =~ ^[Yy]$ ]]; then
    execute_mysql_command "DELETE FROM mysql.user WHERE User='';" "$root_pass"
    echo -e "${GREEN}Anonymous users removed${NC}"
fi

# Step 3: Remote Root Login
echo -e "\n${BLUE}Step 3: Disable Remote Root Login${NC}"
echo -e "${YELLOW}Would you like to disable remote root login? (y/n)${NC}"
read -r disable_remote_root
if [[ "$disable_remote_root" =~ ^[Yy]$ ]]; then
    execute_mysql_command "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" "$root_pass"
    echo -e "${GREEN}Remote root login disabled${NC}"
fi

# Step 4: Remove Test Database
echo -e "\n${BLUE}Step 4: Remove Test Database${NC}"
echo -e "${YELLOW}Would you like to remove the test database? (y/n)${NC}"
read -r remove_test_db
if [[ "$remove_test_db" =~ ^[Yy]$ ]]; then
    execute_mysql_command "DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" "$root_pass"
    echo -e "${GREEN}Test database removed${NC}"
fi

# Step 5: Reload Privileges
echo -e "\n${BLUE}Step 5: Reload Privilege Tables${NC}"
execute_mysql_command "FLUSH PRIVILEGES;" "$root_pass"
echo -e "${GREEN}Privilege tables reloaded${NC}"

# Step 6: Password Validation Policy
echo -e "\n${BLUE}Step 6: Configure Password Validation Policy${NC}"
echo -e "${YELLOW}Would you like to set up password validation policy? (y/n)${NC}"
read -r setup_password_policy
if [[ "$setup_password_policy" =~ ^[Yy]$ ]]; then
    execute_mysql_command "
        SET GLOBAL validate_password_policy=MEDIUM;
        SET GLOBAL validate_password_length=8;
        SET GLOBAL validate_password_mixed_case_count=1;
        SET GLOBAL validate_password_number_count=1;
        SET GLOBAL validate_password_special_char_count=1;
    " "$root_pass"
    echo -e "${GREEN}Password validation policy configured${NC}"
fi

# Final Status Check
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}MySQL/MariaDB security configuration completed!${NC}"
echo -e "${YELLOW}Summary of actions taken:${NC}"
[[ "$change_root_pass" =~ ^[Yy]$ ]] && echo "✓ Root password updated"
[[ "$remove_anonymous" =~ ^[Yy]$ ]] && echo "✓ Anonymous users removed"
[[ "$disable_remote_root" =~ ^[Yy]$ ]] && echo "✓ Remote root login disabled"
[[ "$remove_test_db" =~ ^[Yy]$ ]] && echo "✓ Test database removed"
[[ "$setup_password_policy" =~ ^[Yy]$ ]] && echo "✓ Password validation policy configured"
echo "✓ Privilege tables reloaded"

# Additional Recommendations
echo -e "\n${YELLOW}Additional Security Recommendations:${NC}"
echo "1. Regularly update MySQL/MariaDB to the latest version"
echo "2. Enable binary logging if needed for auditing"
echo "3. Set up regular database backups"
echo "4. Configure SSL/TLS for encrypted connections"
echo "5. Implement regular security audits"

echo -e "\n${BLUE}To connect to MySQL as root, use:${NC}"
echo -e "mysql -u root -p"

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"