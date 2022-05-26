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
sudo rm -rf ./config.yml /usr/local/share/gnome-macos-remap/
# rm -rf ~/.config/gnome-macos-remap/

# Reset gsettings
# Disable overview key ⌘ 
gsettings reset org.gnome.mutter overlay-key
# Set switch applications to ⌘+TAB
gsettings reset org.gnome.desktop.wm.keybindings switch-applications
# Show all applications (with mac's F3 key and imitate spotlight)
gsettings reset org.gnome.shell.keybindings toggle-application-view
# Toggle overview (with mac's F4 key) 
gsettings reset org.gnome.shell.keybindings toggle-overview

# Setting relocatable schema for Terminal
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find

# Restart is optional
echo "Done."
