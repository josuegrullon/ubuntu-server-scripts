# PHP Management Tools 🛠️

Scripts for managing PHP versions on Ubuntu servers.

## 🔄 PHP Version Switcher

Easily switch between installed PHP versions.

```bash
sudo ./php-switcher.sh
```

### Features
- Switch PHP CLI version
- Update PHP-FPM configuration
- Automatic Nginx configuration update
- Installation of missing versions
- System verification

### Common Uses
```bash
# List installed versions
sudo ./php-switcher.sh --list

# Switch to specific version
sudo ./php-switcher.sh
# Then enter version when prompted

# Quick switch
echo "8.1" | sudo ./php-switcher.sh
```

## ⬆️ PHP Upgrader

Upgrade PHP to the latest version with configuration backup.

```bash
sudo ./php-upgrader.sh
```

### Features
- Automatic backup of current configuration
- Installation of required extensions
- Nginx/Apache configuration updates
- PHP-FPM optimization
- System verification

### Common Uses
```bash
# Regular upgrade
sudo ./php-upgrader.sh

# With backup only
sudo ./php-upgrader.sh --backup-only

# Skip confirmations
sudo ./php-upgrader.sh --yes
```

## 🚀 Quick Start

1. Make scripts executable:
```bash
chmod +x php-*.sh
```

2. Run desired tool:
```bash
# For switching versions
sudo ./php-switcher.sh

# For upgrading PHP
sudo ./php-upgrader.sh
```

## ⚠️ Requirements
- Ubuntu 20.04+
- Root/sudo access
- Nginx or Apache
- Active internet connection

## 🔍 Verification
```bash
# Check PHP version
php -v

# Check PHP-FPM status
sudo systemctl status php*-fpm

# Test web server config
sudo nginx -t
# or
sudo apache2ctl -t
```

## 🆘 Troubleshooting

### Common Issues
1. **Version not found**
   ```bash
   sudo apt update
   sudo add-apt-repository ppa:ondrej/php
   ```

2. **FPM not starting**
   ```bash
   sudo systemctl status php*-fpm
   sudo tail -f /var/log/php*-fpm.log
   ```

3. **Web server errors**
   ```bash
   sudo nginx -t
   sudo tail -f /var/log/nginx/error.log
   ```

## 📚 Additional Resources
- [PHP Manual](https://www.php.net/manual/en/)
- [Ubuntu PHP Guide](https://help.ubuntu.com/lts/serverguide/php.html)
- [Nginx PHP FPM Guide](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)
