#!/bin/bash

# Stop and disable the systemd service
sudo systemctl stop gnome-macos-remap
sudo systemctl disable gnome-macos-remap

# Remove xremap executable
sudo rm /usr/local/bin/xremap

# Remove tweak in /usr/share/dbus-1/session.conf - delete line containing "<!-- xremap -->"
sudo sed -i "/xremap/d" /usr/share/dbus-1/session.conf

# TODO: Remove GNOME xremap extension (optional)

# Remove xremap config file
sudo rm ./config.yml /usr/local/share/gnome-macos-remap/
# rm -rf ~/.config/gnome-macos-remap/

# Reset gsettings
# Disable overview key ⌘ 
gsettings reset org.gnome.mutter overlay-key
# Set switch applications to ⌘+TAB
gsettings reset org.gnome.desktop.wm.keybindings switch-applications

# Restart is optional
echo "Done."
