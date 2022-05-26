#!/bin/bash

# Navigate into the ~/Downloads folder
# mkdir -p ~/Downloads && cd ~/Downloads

# Option 1 (not wotking yet)
# Get latest xremap release
# https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
curl -s https://api.github.com/repos/k0kubun/xremap/releases/latest \
| grep "xremap-linux-x86_64-gnome.zip" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -

# Extract the archive and install binary to ~/.local/bin
unzip -o ./xremap-linux-x86_64-gnome.zip
sudo cp ./xremap /usr/local/bin
rm -rf ./xremap*

# Was getting a Permission error when trying to run `xremap` as user. Therefore using sudo
# Sudo requires a tweak in /usr/share/dbus-1/session.conf (according to the xremap readme)
# If installed before - delete line containing "<!-- xremap -->"
echo "Tweaking /usr/share/dbus-1/session.conf..."
sudo sed -i "/xremap/d" /usr/share/dbus-1/session.conf
# Add line: <allow user="root"> <!-- gnome-macos-remap -->
sudo sed -i "s;<policy context=\"default\">;<policy context=\"default\">\n    <allow user=\"root\"/> <!-- xremap -->;g" /usr/share/dbus-1/session.conf

# Copy xremap config file with macOS bindings
# https://stackoverflow.com/questions/1024114/location-of-ini-config-files-in-linux-unix
echo "Copying the xremap config file..."
sudo mkdir -p /usr/local/share/gnome-macos-remap/
sudo cp ./test/config.yml /usr/local/share/gnome-macos-remap/
# mkdir -p ~/.config/systemd/user/
# cp ./config.yml ~/.config/systemd/user/

# Copy systemd service file
echo "Installing systemd service..."
sudo cp ./gnome-macos-remap.service /etc/systemd/system/
# mkdir -p ~/.config/systemd/user
# cp ./gnome-macos-remap.service ~/.config/systemd/user

# Tweak absolute path in systemd service (ExecStart cannot take environment variables)
# sed -i "s;YOUR-HOME-HOLDER;${HOME};g" ~/.config/systemd/user/gnome-macos-remap.service

# Instantiate the service
sudo systemctl daemon-reload
sudo systemctl enable gnome-macos-remap
# systemctl --user daemon-reload
# systemctl --user enable gnome-macos-remap

# Download and enable xremap GNOME extension
# Prerequisites: gnome-shell-extensions
# Enable GNOME Shell user extensions
gsettings set org.gnome.shell disable-user-extensions false
[ -d "./xremap-gnome" ] && rm -rf ./xremap-gnome
echo "Downloading GNOME xremap extension..."
git clone --quiet https://github.com/xremap/xremap-gnome
zip -r -qq xremap-gnome.zip xremap-gnome/
echo "Installing GNOME xremap extension..."
gnome-extensions install --force ./xremap-gnome.zip
rm -rf ./xremap-gnome ./xremap-gnome.zip

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away 
echo "Done. Please restart your computer."
