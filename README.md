# Gnome → macOS Keyboard Remap

This keyboard remap is based on [Key Mapper](https://github.com/sezanzeb/key-mapper) functionality, which is currently in early development. Only a few Nautilus keybindings are implemented at the moment for testing purposes. For a complete and stable solution please refer to the original [Gnome → macOS Keyboard Remap](https://github.com/petrstepanov/gnome-macos-remap) that works with Xorg only.

<figure>
  <img src="https://github.com/petrstepanov/gnome-macos-remap-wayland/blob/master/resources/gnome-macos-remap-wayland.png?raw=true" alt="Gnome macOS Remap Icon" />
</figure>

## How does it work?
The functionality is based on the Key Mapper mechanism. On top of that the default GNOME shell keybindings are modified as well.

## Prerequisities
Install [Git](https://github.com/git/git) and Python 3 with package manager of your choice: 
* On Debian based distributions (Ubuntu, Zorin...) run `sudo apt-get install git python3 python3-dev`.
* On Fedora run `sudo dnf install git python3 python3-devel`.

## Installation
1. Make sure you are running `Wayland` display server. If not sure logout from your session. On the GNOME login screen click ⚙ icon on the bottom right. Select `GNOME`. Log in.
2. Check out the repository to some arbitrary location and run the `install.sh` script in Terminal. Script will ask for administrator password.

```
cd ~/Downloads
git clone https://github.com/petrstepanov/gnome-macos-remap-wayland
cd gnome-macos-remap-wayland
sh install.sh
```

3. Restart your computer.

4. Open Key Mapper. Turn on the `Autoload` switch.

## How to uninstall
1. If repository was removed, check it out again. Navigate into the program directory in Terminal and run:
```
sh uninstall.sh
```
2. Restart your computer.

## Logbook
Dec 13, 2021 • First commit, testing out the Key Mapper.

