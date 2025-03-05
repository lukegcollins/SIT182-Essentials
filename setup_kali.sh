#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (use sudo)"
  exit 1
fi

echo "Updating and upgrading system..."
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove -y
sudo apt autoclean

echo "Installing essential tools..."
sudo apt install -y htop git curl vim gedit net-tools open-vm-tools-desktop virtualbox-guest-x11 \
  apt-transport-https ca-certificates gnupg lsb-release nmap metasploit-framework wordlists torbrowser-launcher snort

# Prepare wordlists
echo "Preparing wordlists..."
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
  sudo gunzip /usr/share/wordlists/rockyou.txt.gz
  echo "rockyou.txt extracted."\else
  echo "rockyou.txt.gz not found, skipping extraction."
fi

# Docker Installation
echo "Setting up Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package lists..."
sudo apt update

echo "Installing Docker and related components..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Adding user to Docker group..."
sudo usermod -aG docker "$USER"

echo "Enabling and starting services..."
sudo systemctl enable --now open-vm-tools
sudo systemctl enable --now docker

echo "Installation complete!"
echo "You may need to reboot for changes to take effect."
