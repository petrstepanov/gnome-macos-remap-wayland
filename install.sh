#!/bin/bash

# Create temporary install directory
BASE_DIR=`pwd`
mkdir -p ~/Downloads && cd ~/Downloads

# Remove previously downloaded archives (if any)
rm -rf ./xremap-linux-x86_64-*

# Detect architecture
ARCH=`uname -m`

# Exit if unsupported architecture
if [ "${ARCH}" != "x86_64" ] && [ "${ARCH}" != "aarch64" ]; then
  echo "ERROR: Unsupported architecture. Please compile and install Xremap manually:"
  echo "       https://github.com/k0kubun/xremap"
  exit 1
fi
echo "INFO: Detected architecture: ${ARCH}"

# Detect compositor type - X11 or Wayland
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  echo "INFO: Detected compositor: X11"
  ARCHIVE_NAME="xremap-linux-${ARCH}-x11.zip"
elif [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "INFO: Detected compositor: Wayland."
  ARCHIVE_NAME="xremap-linux-${ARCH}-gnome.zip"
else
  echo "ERROR: Unsupported compositor."
  exit 0
fi

# Download corresponding archive
echo "INFO: Downloading Xremap archive \"$ARCHIVE_NAME\"..."
curl -s https://api.github.com/repos/k0kubun/xremap/releases/latest \
| grep $ARCHIVE_NAME \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

# Extract the archive and install binary to ~/.local/bin
echo "INFO: Extracting the archive..."
if ! command -v unzip &> /dev/null; then
  echo "ERROR: Command \"unzip\" not found."
  exit 0
fi
unzip -o ./xremap-linux-x86_64-*.zip

echo "INFO: Installing the Xremap binary..."
# sudo systemctl stop gnome-macos-remap
sudo cp ./xremap /usr/local/bin

# Tweaking server access control for X11: https://github.com/k0kubun/xremap#x11
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  xhost +SI:localuser:root
fi

# Sudo requires a tweak in /usr/share/dbus-1/session.conf (according to the xremap readme)
echo "INFO: Tweaking /usr/share/dbus-1/session.conf..."
# If installed before - delete line containing "<!-- xremap -->"
sudo sed -i "/xremap/d" /usr/share/dbus-1/session.conf
# Add line: <allow user="root"> <!-- xremap -->
sudo sed -i "s;<policy context=\"default\">;<policy context=\"default\">\n    <allow user=\"root\"/> <!-- xremap -->;g" /usr/share/dbus-1/session.conf

# Copy xremap config file with macOS bindings
CONFIG_DIR=~/.config/gnome-macos-remap/
echo "INFO: Copying Xremap config file to ${CONFIG_DIR}..."
mkdir -p $CONFIG_DIR
cp $BASE_DIR/config.yml $CONFIG_DIR

# Install PolKit policy to run Xremap with sudo
echo "INFO: Installing the PolKit policy file"
sudo cp $BASE_DIR/com.petrstepanov.gnome-macos-remap-wayland.policy /usr/share/polkit-1/actions
sudo sed -i "s;%HOME%;$HOME;g" /usr/share/polkit-1/actions/com.petrstepanov.gnome-macos-remap-wayland.policy

# Stop systemd service if running
systemctl --user is-active  --quiet gnome-macos-remap.service && systemctl --user stop    gnome-macos-remap.service
systemctl --user is-enabled --quiet gnome-macos-remap.service && systemctl --user disable gnome-macos-remap.service

# Copy systemd service file
SERVICE_DIR=~/.local/share/systemd/user/
echo "INFO: Installing systemd service to ${SERVICE_DIR}"
mkdir -p $SERVICE_DIR
cp $BASE_DIR/gnome-macos-remap.service $SERVICE_DIR

# Instantiate the systemd service
systemctl --user daemon-reload
systemctl --user enable gnome-macos-remap

# Tweak gsettings
echo "INFO: Tweaking GNOME and Mutter keybindings..."

# Ensure system xkb-options are turned off - may interfere
gsettings reset org.gnome.desktop.input-sources xkb-options 

# Disable overview key ⌘ - interferes with ⌘ + ... combinations
gsettings set org.gnome.mutter overlay-key ''

# Minimize one window and all windows - conflicts with show hidden files in Nautilus
gsettings set org.gnome.desktop.wm.keybindings minimize "[]"

# Minimize all windows
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Control>d']"

# Set switch applications to ⌘+TAB, switch application windows ⌘+`
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Control>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Control>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Control>grave']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Control>grave']"

# ⌘ - Space hotkey for spotlight functionality conflicts with default Gnome switch-input-source shortcut
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"

# Switch workspaces conflicts with default GNOME window left/right tiling
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "[]"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "[]"

# Switch workspaces
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Right']"

# Paste in terminal (if set via Ctrl+V, not Shift+Ctrl+V) interferes with default GNOME show notification panel shortcut
gsettings set org.gnome.shell.keybindings toggle-message-tray "[]"

# Toggle overview (with mac's F3 key)
gsettings set org.gnome.shell.keybindings toggle-overview "['LaunchA']"

# Show all applications (with mac's F4 key and imitate spotlight)
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Primary>space', 'LaunchB']"

# Setting relocatable schema for Terminal
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy '<Shift><Super>c'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste '<Shift><Super>v'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab '<Shift><Super>t'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window '<Shift><Super>n'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab '<Shift><Super>w'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window '<Shift><Super>q'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find '<Shift><Super>f'

# Screenshots
gsettings set org.gnome.shell.keybindings screenshot "['<Shift><Control>3']"
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Control>4']"
gsettings set org.gnome.shell.keybindings screenshot-window "['<Shift><Control>5']"

# Disable screensaver to avoid potential issues
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away

echo "INFO: Installation successfully completed."

# Remind user to install Xremap GNOME extension (for Wayland only)
echo ""
if [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "Important! Please install the Xremap extension and restart your computer."
  echo "https://extensions.gnome.org/extension/5060/xremap/"
else
  gnome-extensions disable xremap@k0kubun.com
  echo "Important! Please restart your computer."
fi
echo ""
