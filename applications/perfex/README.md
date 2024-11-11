# Perfex CRM Installation Tools 🚀

Automated installation and management scripts for Perfex CRM on Ubuntu Server with LEMP stack (Linux, Nginx, MySQL, PHP).

## 📦 Available Scripts

### 1. Perfex Installer (`perfex-installer.sh`)
Complete LEMP stack installation with Perfex CRM setup.

```bash
sudo ./perfex-installer.sh
```

Key features:
- Interactive domain configuration
- Automatic SSL certificate setup
- PHP optimization
- MariaDB configuration
- Nginx server blocks
- System verification

### 2. Perfex Uninstaller (`perfex-uninstaller.sh`)
Clean removal of Perfex CRM and optional LEMP stack components.

```bash
sudo ./perfex-uninstaller.sh
```

Key features:
- Database backup before removal
- Configuration preservation options
- Complete or selective removal
- SSL certificate cleanup
- System restoration

## 🔧 System Requirements

- Ubuntu 20.04 LTS or higher
- Minimum 2GB RAM
- 20GB free disk space
- Root/sudo access
- Clean system recommended

## 🚀 Quick Installation

1. Prepare Installation:
```bash
# Clone repository
git clone https://github.com/yourusername/ubuntu-server-toolkit.git

# Navigate to Perfex tools
cd ubuntu-server-toolkit/install

# Make scripts executable
chmod +x perfex-*.sh
```

2. Start Installation:
```bash
sudo ./perfex-installer.sh
```

## ⚙️ What Gets Installed

### Web Server
- Nginx with optimized configuration
- SSL/TLS certificates via Let's Encrypt
- Optimized server blocks
- Security headers

### Database
- MariaDB 10.x
- Optimized for performance
- Secure default configuration
- Automated database creation

### PHP
- PHP 8.x with required extensions
- Optimized php.ini
- PHP-FPM configuration
- OpCache settings

### Additional Components
- phpMyAdmin (optional)
- Certbot for SSL
- System utilities
- Backup tools

## 🛠️ Configuration Options

### Domain Setup
```bash
# The script will prompt for:
- Domain name (e.g., crm.yourdomain.com)
- SSL certificate details
- DNS verification
```

### Database Configuration
```bash
# You'll be asked to set:
- Database name
- Username
- Secure password
- Backup preferences
```

### PHP Settings
```bash
# Customizable options:
- Memory limit
- Upload size
- Execution time
- Error reporting
```

## 📋 Post-Installation Steps

1. Complete Perfex Setup:
```bash
# Access your domain
https://your-domain.com/install

# Follow the web installer
- Database details
- Admin account
- System settings
```

2. Verify Installation:
```bash
# Check services
sudo systemctl status nginx
sudo systemctl status mysql
sudo systemctl status php8.1-fpm

# Check SSL
curl -vI https://your-domain.com
```

3. Secure Your Installation:
```bash
# File permissions
sudo ./secure-permissions.sh

# Configure firewall
sudo ufw allow 'Nginx Full'
```

## 🔄 Backup & Maintenance

### Automated Backups
```bash
# Database backup
./backup-db.sh

# Files backup
./backup-files.sh
```

### Updates
```bash
# System updates
sudo apt update && sudo apt upgrade

# PHP updates
./php-upgrader.sh
```

## 🚨 Troubleshooting

### Common Issues

1. Installation Fails
```bash
# Check logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/php8.1-fpm.log
```

2. Database Connection
```bash
# Verify MariaDB
sudo systemctl status mariadb
mysql -u root -p
```

3. Permission Issues
```bash
# Reset permissions
sudo chown -R www-data:www-data /var/www/perfex
sudo chmod -R 755 /var/www/perfex
```

4. SSL Problems
```bash
# Check certificate
sudo certbot certificates
sudo certbot renew --dry-run
```

## 🔒 Security Recommendations

1. Regular Updates
```bash
# Create update schedule
sudo crontab -e
```

2. Firewall Configuration
```bash
sudo ufw enable
sudo ufw status
```

3. SSL Maintenance
```bash
# Auto-renewal verification
sudo certbot renew --dry-run
```

4. File Permissions
```bash
# Regular checks
sudo ./check-permissions.sh
```

## 🔄 Upgrade Guide

1. Backup First
```bash
# Full backup
./backup-all.sh
```

2. Update System
```bash
sudo apt update
sudo apt upgrade
```

3. Update Perfex
```bash
# Follow Perfex's upgrade guide
./update-perfex.sh
```

## 🗑️ Uninstallation

1. Backup Data
```bash
# Full backup before removal
sudo ./perfex-uninstaller.sh --backup
```

2. Remove Components
```bash
# Complete removal
sudo ./perfex-uninstaller.sh --all

# Selective removal
sudo ./perfex-uninstaller.sh --select
```

## 📝 Logs

Find logs in:
- `/var/log/nginx/`
- `/var/log/php/`
- `/var/log/mysql/`
- `/var/log/perfex/`

## ⚡ Performance Optimization

1. PHP-FPM Settings
```bash
# Optimize based on server resources
sudo nano /etc/php/8.1/fpm/pool.d/www.conf
```

2. Nginx Configuration
```bash
# Enable caching
sudo nano /etc/nginx/conf.d/cache.conf
```

3. MariaDB Tuning
```bash
# Performance optimization
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

## 🆘 Support

1. Check Logs:
```bash
# Combined log view
sudo tail -f /var/log/{nginx/error.log,php8.1-fpm.log,mysql/error.log}
```

2. System Status:
```bash
# Service status
sudo systemctl status {nginx,mariadb,php8.1-fpm}
```

3. Debug Mode:
```bash
# Enable debugging
./perfex-installer.sh --debug
```

## 📚 Additional Resources

- [Perfex CRM Documentation](https://help.perfexcrm.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [PHP Documentation](https://www.php.net/docs.php)
