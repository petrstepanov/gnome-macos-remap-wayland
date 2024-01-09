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

# Reset gsettings
echo "INFO: Resetting GNOME and Mutter keybindings..."

# Disable overview key ⌘ - interferes with ⌘ + ... combinations
gsettings reset org.gnome.mutter overlay-key

# Minimize one window and all windows - conflicts with show hidden files in Nautilus
# gsettings reset org.gnome.desktop.wm.keybindings minimize "['<Control>h']"
gsettings reset org.gnome.desktop.wm.keybindings minimize

# Minimize all windows
gsettings reset org.gnome.desktop.wm.keybindings show-desktop

# Set switch applications to ⌘+TAB, switch application windows ⌘+`
gsettings reset org.gnome.desktop.wm.keybindings switch-applications
gsettings reset org.gnome.desktop.wm.keybindings switch-applications-backward
gsettings reset org.gnome.desktop.wm.keybindings switch-group
gsettings reset org.gnome.desktop.wm.keybindings switch-group-backward

# ⌘ - Space hotkey for spotlight functionality conflicts with default Gnome switch-input-source shortcut
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source-backward

# Switch workspaces conflicts with default GNOME window left/right tiling
gsettings reset org.gnome.mutter.keybindings toggle-tiled-left
gsettings reset org.gnome.mutter.keybindings toggle-tiled-right

# Switch workspaces
gsettings reset org.gnome.desktop.wm.keybindings switch-to-workspace-left
gsettings reset org.gnome.desktop.wm.keybindings switch-to-workspace-right

# Paste in terminal (if set via Ctrl+V, not Shift+Ctrl+V) interferes with default GNOME show notification panel shortcut
gsettings reset org.gnome.shell.keybindings toggle-message-tray

# Toggle overview (with mac's F3 key)
gsettings reset org.gnome.shell.keybindings toggle-overview

# Show all applications (with mac's F4 key and imitate spotlight)
gsettings reset org.gnome.shell.keybindings toggle-application-view

# Setting relocatable schema for Terminal
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window
gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find

# Screenshots
gsettings reset org.gnome.shell.keybindings screenshot
gsettings reset org.gnome.shell.keybindings show-screenshot-ui
gsettings reset org.gnome.shell.keybindings screenshot-window

# Disable screensaver to avoid potential issues
gsettings reset org.gnome.settings-daemon.plugins.media-keys screensaver

# TODO: Remove GNOME xremap extension (optional)
