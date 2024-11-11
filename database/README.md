# MySQL/MariaDB Security Tools 🛡️

A collection of security-focused scripts for MySQL/MariaDB database administration and hardening.

## 🔧 Available Scripts

### 1. MySQL Access Fix (`mysql-access-fix.sh`)
Repairs and resets root access when locked out of MySQL/MariaDB.

```bash
sudo ./mysql-access-fix.sh
```

Key features:
- Interactive password setup
- Safe mode database access
- Password strength validation
- Configuration backup
- Service status verification

### 2. MySQL Security Configuration (`mysql-secure-interactive.sh`)
Interactive security hardening script for MySQL/MariaDB installations.

```bash
sudo ./mysql-secure-interactive.sh
```

Key features:
- Root password management
- Anonymous user removal
- Remote access control
- Test database cleanup
- Password policy configuration
- Privilege table management

## 🚀 Quick Start

1. Make scripts executable:
```bash
chmod +x *.sh
```

2. Run the script you need:
```bash
# If you're locked out of MySQL:
sudo ./mysql-access-fix.sh

# To secure your MySQL installation:
sudo ./mysql-secure-interactive.sh
```

## 📋 Requirements

- Ubuntu 20.04 LTS or later
- Root/sudo privileges
- MySQL 5.7+ or MariaDB 10.3+

## 🔐 Security Features

### Password Policy
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

### Database Hardening
- Removal of anonymous users
- Restriction of root account to localhost
- Removal of test database
- Password validation policy
- Privilege table management

## 🔍 Verification Steps

After running the security script, verify your setup:

1. Test root login:
```bash
mysql -u root -p
```

2. Check for anonymous users:
```sql
SELECT User, Host FROM mysql.user;
```

3. Verify remote connections:
```sql
SELECT User, Host FROM mysql.user WHERE User='root';
```

## ⚠️ Common Issues and Solutions

### 1. Access Denied
```bash
# Use the access fix script
sudo ./mysql-access-fix.sh
```

### 2. Failed to Start MySQL
```bash
# Check MySQL status
sudo systemctl status mysql

# View error logs
sudo tail -f /var/log/mysql/error.log
```

### 3. Password Policy Issues
```sql
-- Check password policy settings
SHOW VARIABLES LIKE 'validate_password%';
```

## 📝 Logging

All scripts include:
- Color-coded output
- Operation confirmation
- Error logging
- Success verification
- Status reporting

## 🔄 Backup and Recovery

Before making changes:
- Database configurations are automatically backed up
- Current users and privileges are preserved
- Safe mode options for recovery

## 🛠️ Customization

Edit the scripts to modify:
- Password requirements
- Security policies
- Backup locations
- Color schemes
- Default configurations

## 🔒 Best Practices

1. Regular Updates
```bash
sudo apt update
sudo apt upgrade mysql-server
```

2. Backup Schedule
```bash
# Create a backup
mysqldump -u root -p --all-databases > backup.sql
```

3. Monitor Logs
```bash
sudo tail -f /var/log/mysql/error.log
```

4. Check Connections
```sql
SHOW PROCESSLIST;
```

## 🚫 Warning

- Always backup before running security scripts
- Test in non-production environment first
- Keep root password in a secure location
- Monitor logs for unauthorized access attempts

## 🆘 Troubleshooting

### Access Issues
```bash
# Check MySQL status
sudo systemctl status mysql

# View error logs
sudo tail -f /var/log/mysql/error.log
```

### Configuration Problems
```bash
# Check MySQL configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

### Connection Problems
```bash
# Check MySQL binding
sudo netstat -tlpn | grep mysql
```

## 📚 Additional Resources

- [MySQL Documentation](https://dev.mysql.com/doc/)
- [MariaDB Security Guide](https://mariadb.com/kb/en/security/)
- [Ubuntu MySQL Guide](https://ubuntu.com/server/docs/databases-mysql)
