#!/bin/bash

# Stop and disable the systemd service
sudo systemctl stop gnome-macos-remap
sudo systemctl disable gnome-macos-remap

# Remove xremap executable
sudo rm /usr/local/bin/xremap

# Remove tweak in /usr/share/dbus-1/session.conf - delete line containing "<!-- xremap -->"
sudo sed -i "/xremap/d" /usr/share/dbus-1/session.conf

# Remove xremap config file
sudo rm -rf /usr/local/share/gnome-macos-remap/

# TODO: Remove GNOME xremap extension (optional)
