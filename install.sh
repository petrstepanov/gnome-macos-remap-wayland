#!/bin/bash

# Navigate into the ~/Downloads folder
# mkdir -p ~/Downloads && cd ~/Downloads

# Option 1 (not wotking yet)
# Get latest xremap release
# https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
# curl -s https://api.github.com/repos/k0kubun/xremap/releases/latest \
# | grep "xremap-linux-x86_64-gnome.zip" \
# | cut -d : -f 2,3 \
# | tr -d \" \
# | wget -qi -

# Extract the archive and install binary to ~/.local/bin
# unzip -o ./xremap-linux-x86_64-gnome.zip
# sudo cp ./xremap /usr/local/bin

# Option 2
# Install Rust and build with `cargo`
# Prerequisites: 
# 1. Install Rust:  curl https://sh.rustup.rs -sSf | sh
# 2. Restart GNOME: killall -3 gnome-shell
# cargo install xremap --features gnome

# Option 3
# Build and install xremap from latest master branch
# Benefit - compiles for your particular architecture.
# Prerequisites: 
# 1. Install Rust:  curl https://sh.rustup.rs -sSf | sh
# 2. Restart GNOME: killall -3 gnome-shell
[ -d "./xremap" ] && rm -rf ./xremap
echo "Cloning xremap repository..."
git clone --quiet https://github.com/k0kubun/xremap
cd ./xremap
echo "Compiling xremap executable..."
cargo build --features gnome
sudo cp ./target/debug/xremap /usr/local/bin
cd ..
rm -rf ./xremap

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
sudo cp ./config.yml /usr/local/share/gnome-macos-remap/
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

# Tweak gsettings
echo "Tweaking gsettings..."
# Disable overview key ⌘ 
gsettings set org.gnome.mutter overlay-key 'Super_R'

# Set switch applications to ⌘+TAB
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Primary>Tab']"

# Show all applications (with mac's F3 key and imitate spotlight)
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Primary>space', 'LaunchB']"

# Toggle overview (with mac's F4 key) 
gsettings set org.gnome.shell.keybindings toggle-overview "['LaunchA']"

# Setting relocatable schema for Terminal
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy '<Primary>c'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste '<Primary>v'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab '<Primary>t'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window '<Primary>n'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab '<Primary>w'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window '<Primary>q'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find '<Primary>f'

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away 
echo "Done. Please restart your computer."
