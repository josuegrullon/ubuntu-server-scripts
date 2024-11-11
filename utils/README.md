# Quick System Utilities 🛠️

Simple utilities for common system tasks.

## Available Scripts

### 1. IP Information (`my-ip.sh`)
Display internal and external IP addresses.

```bash
chmod +x my-ip.sh
./my-ip.sh
```

Features:
- External IP detection
- Internal IP listing
- Multiple fallback sources

### 2. System Update (`my-up.sh`)
Quick system update and upgrade.

```bash
chmod +x my-up.sh
sudo ./my-up.sh
```

Features:
- System update
- Package upgrade
- Auto cleanup
- Service status check

## Quick Install
```bash
# Make executable
chmod +x my-*.sh

# Add to path (optional)
sudo cp my-*.sh /usr/local/bin/
```

## Usage Examples
```bash
# Get IP info
./my-ip.sh

# Update system
sudo ./my-up.sh
```

## Requirements
- Ubuntu/Debian
- curl or wget
- Root access (for my-up.sh)

## 🔧 Maintenance
- Keep scripts up to date
- Check for new IP sources
- Verify package sources