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
git clone --quiet https://github.com/k0kubun/xremap
cd ./xremap
cargo build --features gnome
sudo cp ./target/debug/xremap /usr/local/bin
cd ..
rm -rf ./xremap

# Was getting a Permission error when trying to run `xremap` as user. Therefore using sudo
# Sudo requires a tweak in /usr/share/dbus-1/session.conf (according to the xremap readme)
# If installed before - delete line containing "<!-- xremap -->"
sudo sed -i "/xremap/d" /usr/share/dbus-1/session.conf
# Add line: <allow user="root"> <!-- gnome-macos-remap -->
sudo sed -i "s;<policy context=\"default\">;<policy context=\"default\">\n    <allow user=\"root\"/> <!-- xremap -->;g" /usr/share/dbus-1/session.conf

# Install GNOME extension installer to install extensions from Terminal
# wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
#chmod +x ./gnome-shell-extension-installer
# mv ./gnome-shell-extension-installer ~/.local/bin/
# gnome-shell-extension-installer 5060 --yes

# Download and enable xremap GNOME extension
# Prerequisites: gnome-shell-extensions
# Enable GNOME Shell user extensions
gsettings set org.gnome.shell disable-user-extensions false
[ -d "./xremap-gnome" ] && rm -rf ./xremap-gnome
git clone --quiet https://github.com/xremap/xremap-gnome
zip -r xremap-gnome.zip xremap-gnome/
gnome-extensions install --force ./xremap-gnome.zip
rm -rf ./xremap-gnome ./xremap-gnome.zip

# Copy xremap config file with macOS bindings
mkdir -p ~/.config/gnome-macos-remap/
cp ./config.yml ~/.config/gnome-macos-remap/

# Copy systemd service file
# mkdir -p ~/.config
# mkdir -p ~/.config/systemd
# mkdir -p ~/.config/systemd/user
# cp ./gnome-macos-remap.service ~/.config/systemd/user
sudo cp ./gnome-macos-remap@.service /etc/systemd/system/

# Tweak absolute path in systemd service (ExecStart cannot take environment variables)
sudo sed -i "s;HOME;${HOME};g" /etc/systemd/system/gnome-macos-remap@.service

# Instantiate the service
# systemctl --user enable gnome-macos-remap
sudo systemctl daemon-reload
# sudo systemctl enable gnome-macos-remap@$USER

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away 
# sudo systemctl start gnome-macos-remap@$USER

echo "Done. Please restart your computer."

# Tweak gsettings
# Disable overview key ⌘ 
gsettings set org.gnome.mutter overlay-key ''
# Set switch applications to ⌘+TAB
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Primary>Tab']"

