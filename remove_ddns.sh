#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Delete files
INSTALL_DIR="/opt/ddns"
rm -rf "$INSTALL_DIR"

# Stop services
systemctl stop ddns.timer 2>/dev/null
systemctl disable ddns.timer 2>/dev/null

# Remove symlinks
rm -rf "/usr/sbin/ddns"
rm -rf "/etc/systemd/system/ddns.service"
rm -rf "/etc/systemd/system/ddns.timer"

# Reload and reset failed
systemctl daemon-reload
sudo systemctl reset-failed ddns.service 2>/dev/null
sudo systemctl reset-failed ddns.timer 2>/dev/null
