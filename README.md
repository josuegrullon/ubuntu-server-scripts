# (USS) ubuntu-server-scripts 🛠️

A collection of production-ready scripts for Ubuntu server management and common web stack deployment.

## 🎯 Features

- **LAMP/LEMP Stack Management**
  - Perfex CRM Installation/Uninstallation
  - PHP Version Management
  - MySQL/MariaDB Administration
  - Nginx Configuration

- **Security Tools**
  - SSL Certificate Management
  - Database Security
  - Backup Solutions

- **System Utilities**
  - IP Address Tools
  - System Information
  - Performance Monitoring



## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/josuegrullon/ubuntu-server-toolkit.git

# Make scripts executable
cd ubuntu-server-toolkit
chmod +x install/*.sh database/*.sh php/*.sh security/*.sh utils/*.sh

# Run the script you need
./install/perfex-installer.sh
```

## 📝 Usage Guidelines

Each script follows these principles:
- Interactive prompts for critical decisions
- Automatic backup before major changes
- Comprehensive error handling
- Color-coded output for clarity
- Step-by-step verification
- Detailed logging

## 🔒 Security Features

- Configuration backups
- Password strength validation
- SSL/TLS integration
- Secure default configurations
- Input validation

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📜 License

MIT License - feel free to use in personal and commercial projects.

## ⚠️ Disclaimer

These scripts are provided as-is. Always test in a staging environment first.