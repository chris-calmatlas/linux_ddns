#!/bin/bash
INSTALL_DIR="/opt/ddns"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Move files to opt
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
mkdir -p "$INSTALL_DIR" || { echo "Cannot mkdir $INSTALL_DIR"; exit 1; }
cp -R "$script_dir"/* "$INSTALL_DIR"

# Copy .env if it exists
cp "$script_dir/.env" "$INSTALL_DIR" 2>/dev/null

#Check files and perms
dotenv="$INSTALL_DIR/.env"
if [ -f "$dotenv" ]; then
  chmod 400 $dotenv
else
  echo "Could not find .env"
  echo "Make a .env in $INSTALL_DIR or $script_dir"
  echo "then re-run this install script"
  exit 2
fi
chmod u+x "$INSTALL_DIR/update_cloudflareddns.sh"

# symlinks
ln -sf "$INSTALL_DIR/update_cloudflareddns.sh" "/usr/sbin/ddns" || { echo "Could not create /usr/sbin/ddns"; exit 1; }
ln -sf "$INSTALL_DIR/ddns.service" "/etc/systemd/system/ddns.service" || { echo "Could not create /etc/systemd/system/ddns.service"; exit 1; }
ln -sf "$INSTALL_DIR/ddns.timer" "/etc/systemd/system/ddns.timer" || { echo "Could not create /etc/systemd/system/ddns.timer"; exit 1; }

read -p "Autostart and run every 10 minutes? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl enable ddns.timer --now
fi

read -p "Remove these installer files? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf $script_dir
fi