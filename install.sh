#!/bin/bash

# Create temporary install directory
BASE_DIR=`pwd`
mkdir -p ~/Downloads && cd ~/Downloads

# Remove previously downloaded archives (if any)
rm -rf ./xremap-linux-x86_64-*

# Detect compositor type - X11 or Wayland
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  echo "INFO: Detected X11."
  ARCHIVE_NAME="xremap-linux-x86_64-x11.zip"
elif [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "INFO: Detected Wayland."
  ARCHIVE_NAME="xremap-linux-x86_64-gnome.zip"
else
  echo "ERROR: Unsupported compositor."
  exit 0
fi

# Download corresponding archive
echo "INFO: Downloading the \"$ARCHIVE_NAME\"..."
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

echo "INFO: Installing the binary..."
# sudo systemctl stop gnome-macos-remap
sudo cp ./xremap /usr/local/bin

# Tweaking server access control for X11 https://github.com/k0kubun/xremap#x11
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
# https://stackoverflow.com/questions/1024114/location-of-ini-config-files-in-linux-unix
echo "INFO: Copying the xremap config file..."
sudo mkdir -p /usr/local/share/gnome-macos-remap/
sudo cp $BASE_DIR/config.yml /usr/local/share/gnome-macos-remap/

# Copy systemd service file
#echo "INFO: Installing systemd service..."
#sudo cp $BASE_DIR/gnome-macos-remap.service /etc/systemd/system/

# Instantiate the service (for sudo) - may work for Wayland because this runs before login screen when X11 is inactive??
# Try later
#sudo systemctl daemon-reload
#sudo systemctl enable gnome-macos-remap

# Instantiate the service (for local user)
#systemctl --user daemon-reload
#systemctl --user enable gnome-macos-remap

# Install python scripts for Terminal
# echo "INFO: Copying Python scripts..."
# pip install pynput
# cp $BASE_DIR/python/*.py ~/.local/bin
# chmod +x ~/.local/bin/*.py

# Install bash scripts for Terminal
echo "INFO: Copying bash scripts..."
cp $BASE_DIR/bin/terminal*.sh ~/.local/bin
chmod +x ~/.local/bin/terminal*.sh

echo "INFO: Creating autostart entry..."
# Install application icon
mkdir -p ~/.local/share/icons/hicolor/scalable/apps/
cp $BASE_DIR/resources/gnome-macos-remap.svg ~/.local/share/icons/hicolor/scalable/apps/

# Create autostart entry (systemd option not working not sure why)
cp $BASE_DIR/resources/gnome-macos-remap.desktop ~/.config/autostart/
chmod +x ~/.config/autostart/gnome-macos-remap.desktop

# Create autostart script
mkdir -p ~/.local/bin
cp $BASE_DIR/resources/gnome-macos-remap.sh ~/.local/bin
chmod +x ~/.local/bin/gnome-macos-remap.sh

# Download and enable xremap GNOME extension (for Wayland only)
if [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "INFO: Installing GNOME extension (for Wayland)."
  # Prerequisites: gnomes-extensions
  if ! command -v gnome-extensions &> /dev/null; then
    echo "ERROR: Command \"gnome-extensions\" not found."
    exit 0
  fi  
  gsettings set org.gnome.shell disable-user-extensions false
  [ -d "./xremap-gnome" ] && rm -rf ./xremap-gnome
  echo "INFO: Downloading GNOME xremap extension..."
  git clone --quiet https://github.com/xremap/xremap-gnome
  zip -r -qq xremap-gnome.zip xremap-gnome/
  echo "INFO: Installing GNOME xremap extension..."
  gnome-extensions install --force ./xremap-gnome.zip
  rm -rf ./xremap-gnome ./xremap-gnome.zip
  gnome-extensions enable xremap@k0kubun.com
else
  gnome-extensions disable xremap@k0kubun.com
fi

# Tweak gsettings
echo "INFO: Tweaking GNOME and Mutter keybindings..."

# Disable overview key ⌘ - interferes with ⌘ + ... combinations
gsettings set org.gnome.mutter overlay-key ''

# Minimize one window and all windows - conflicts with show hidden files in Nautilus
# gsettings set org.gnome.desktop.wm.keybindings minimize "['<Control>h']"
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
gsettings set org.gnome.shell.keybindings screenshot "['<Primary><Shift>numbersign']"
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Control>dollar']"
gsettings set org.gnome.shell.keybindings screenshot-window "['<Shift><Control>percent']"

# Disable screensaver to avoid potential issues
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away

echo "INFO: Done. Please restart your computer."
