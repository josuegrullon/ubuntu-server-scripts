#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get service status with color
get_service_status() {
    local service=$1
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}Active${NC}"
    else
        echo -e "${RED}Inactive${NC}"
    fi
}

# Function to format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(( bytes / 1024 ))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(( bytes / 1048576 ))MB"
    else
        echo "$(( bytes / 1073741824 ))GB"
    fi
}

# Function to get database info
get_db_info() {
    local db_type=$1
    if systemctl is-active --quiet $db_type; then
        local version
        case $db_type in
            mysql|mariadb)
                version=$(mysql --version 2>/dev/null)
                ;;
            postgresql)
                version=$(psql --version 2>/dev/null)
                ;;
        esac
        echo -e "${GREEN}Installed${NC} - $version"
    else
        echo -e "${RED}Not installed${NC}"
    fi
}

# Clear screen and show header
clear
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}                    System Information Report                    ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "Generated on: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "Hostname: $(hostname)"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

# System Information
echo -e "\n${YELLOW}📊 System Information${NC}"
echo -e "${CYAN}OS:${NC}            $(lsb_release -d | cut -f2)"
echo -e "${CYAN}Kernel:${NC}        $(uname -r)"
echo -e "${CYAN}Architecture:${NC}   $(uname -m)"
echo -e "${CYAN}Uptime:${NC}        $(uptime -p)"

# CPU Information
echo -e "\n${YELLOW}💻 CPU Information${NC}"
echo -e "${CYAN}Model:${NC}         $(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^[ \t]*//')"
echo -e "${CYAN}Cores:${NC}         $(grep -c "processor" /proc/cpuinfo)"
echo -e "${CYAN}CPU Usage:${NC}     $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"

# Memory Information
echo -e "\n${YELLOW}💾 Memory Information${NC}"
total_mem=$(free -b | grep Mem | awk '{print $2}')
used_mem=$(free -b | grep Mem | awk '{print $3}')
free_mem=$(free -b | grep Mem | awk '{print $4}')
echo -e "${CYAN}Total Memory:${NC}   $(format_bytes $total_mem)"
echo -e "${CYAN}Used Memory:${NC}    $(format_bytes $used_mem)"
echo -e "${CYAN}Free Memory:${NC}    $(format_bytes $free_mem)"
echo -e "${CYAN}Memory Usage:${NC}   $(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)%"

# Disk Information
echo -e "\n${YELLOW}💿 Disk Information${NC}"
echo -e "${CYAN}Disk Usage:${NC}"
df -h | grep '^/dev/' | while read -r line; do
    device=$(echo "$line" | awk '{print $1}')
    size=$(echo "$line" | awk '{print $2}')
    used=$(echo "$line" | awk '{print $3}')
    avail=$(echo "$line" | awk '{print $4}')
    use_percent=$(echo "$line" | awk '{print $5}')
    mounted=$(echo "$line" | awk '{print $6}')
    echo -e "  ${PURPLE}$device${NC} ($mounted)"
    echo -e "  ├─ Size: $size"
    echo -e "  ├─ Used: $used"
    echo -e "  ├─ Available: $avail"
    echo -e "  └─ Usage: $use_percent"
done

# Network Information
echo -e "\n${YELLOW}🌐 Network Information${NC}"
echo -e "${CYAN}Hostname:${NC}      $(hostname)"
echo -e "${CYAN}IP Addresses:${NC}"
ip -4 addr show | grep inet | grep -v "127.0.0.1" | while read -r line; do
    ip=$(echo "$line" | awk '{print $2}')
    interface=$(echo "$line" | awk '{print $NF}')
    echo -e "  ├─ $interface: $ip"
done
if command_exists curl; then
    public_ip=$(curl -s https://api.ipify.org)
    echo -e "  └─ Public IP: $public_ip"
fi

# Services Status
echo -e "\n${YELLOW}🔌 Services Status${NC}"
services=("nginx" "apache2" "mysql" "mariadb" "postgresql" "php-fpm" "redis-server" "memcached")
for service in "${services[@]}"; do
    if systemctl list-unit-files | grep -q "$service"; then
        status=$(get_service_status $service)
        echo -e "${CYAN}$service:${NC} $status"
    fi
done

# PHP Information
echo -e "\n${YELLOW}🐘 PHP Information${NC}"
if command_exists php; then
    echo -e "${CYAN}Version:${NC}        $(php -v | grep -oP "PHP \K[0-9]+\.[0-9]+\.[0-9]+" | head -n1)"
    echo -e "${CYAN}Extensions:${NC}      $(php -m | wc -l) loaded"
    echo -e "${CYAN}PHP-FPM:${NC}        $(systemctl is-active php*-fpm | head -n1)"
else
    echo -e "${RED}PHP is not installed${NC}"
fi

# Database Information
echo -e "\n${YELLOW}🗄️ Database Information${NC}"
echo -e "${CYAN}MySQL:${NC}         $(get_db_info mysql)"
echo -e "${CYAN}MariaDB:${NC}       $(get_db_info mariadb)"
echo -e "${CYAN}PostgreSQL:${NC}    $(get_db_info postgresql)"

# Security Information
echo -e "\n${YELLOW}🔒 Security Information${NC}"
echo -e "${CYAN}Firewall Status:${NC}"
if command_exists ufw; then
    echo -e "  ├─ UFW: $(ufw status | grep Status | cut -d: -f2)"
elif command_exists iptables; then
    echo -e "  ├─ IPTables: Active"
else
    echo -e "  ├─ No firewall detected"
fi

# SSL Certificates
echo -e "${CYAN}SSL Certificates:${NC}"
if command_exists certbot; then
    certbot certificates 2>/dev/null | grep "Certificate Name" | while read -r line; do
        cert_name=$(echo "$line" | cut -d: -f2)
        echo -e "  ├─ $cert_name"
    done
else
    echo -e "  ├─ Certbot not installed"
fi

# System Load
echo -e "\n${YELLOW}📈 System Load Average${NC}"
load_1min=$(cut -d' ' -f1 /proc/loadavg)
load_5min=$(cut -d' ' -f2 /proc/loadavg)
load_15min=$(cut -d' ' -f3 /proc/loadavg)
echo -e "${CYAN}1 minute:${NC}      $load_1min"
echo -e "${CYAN}5 minutes:${NC}     $load_5min"
echo -e "${CYAN}15 minutes:${NC}    $load_15min"

# Last System Updates
echo -e "\n${YELLOW}🔄 System Updates${NC}"
echo -e "${CYAN}Last Update:${NC}    $(ls -lt /var/log/apt/history.log | head -n1 | awk '{print $6, $7, $8}')"
echo -e "${CYAN}Updates Available:${NC} $(apt list --upgradable 2>/dev/null | grep -c upgradable)"

# Write to file option
report_file="system_report_$(date +%Y%m%d_%H%M%S).txt"
echo -e "\n${YELLOW}Would you like to save this report to a file? (y/n)${NC}"
read -r save_report
if [[ $save_report =~ ^[Yy]$ ]]; then
    script -q -c "$(realpath $0) --no-prompt" "$report_file" >/dev/null
    echo -e "${GREEN}Report saved to: $report_file${NC}"
fi

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "Report Complete!"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"