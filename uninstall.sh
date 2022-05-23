#!/bin/bash

# Stop and disable the systemd service
sudo systemctl stop gnome-macos-remap@$USER
sudo systemctl disable gnome-macos-remap@$USER

# Remove xremap executable
sudo rm /usr/local/bin/xremap

# Remove tweak in /usr/share/dbus-1/session.conf - delete line containing "<!-- xremap -->"
sudo sed -i "/xremap/d" /usr/share/dbus-1/session.conf

# TODO: Remove GNOME xremap extension

# Remove xremap config file
rm -rf ~/.config/gnome-macos-remap/

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away 
# sudo systemctl start gnome-macos-remap@$USER

# Tweak gsettings
# Disable overview key ⌘ 
gsettings reset org.gnome.mutter overlay-key
# Set switch applications to ⌘+TAB
gsettings reset org.gnome.desktop.wm.keybindings switch-applications
