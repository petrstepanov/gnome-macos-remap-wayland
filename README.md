# Gnome → macOS Keyboard Remap for Wayland (in progress...)

This keyboard remap is based on the [xRemap](https://github.com/k0kubun/xremap) functionality. Currently repository is in the early development. Only a few keybindings are implemented at the moment for testing purposes. For a complete and stable solution please refer to the original [Gnome → macOS Keyboard Remap](https://github.com/petrstepanov/gnome-macos-remap) that works with Xorg only.

<figure>
  <img src="https://raw.githubusercontent.com/petrstepanov/gnome-macos-remap-wayland/main/resources/gnome-macos-remap-wayland.png?raw=true" alt="Gnome macOS Remap Icon" />
</figure>

## How does it work?
Script builds latest version of the `xremap` for your architecture. Configuration file `config.yaml` contains majority of the remapping instructions. On top of that the default GNOME shell keybindings are modified. A systemd service is created and enabled for a particular user. Therefore after the install other users on the system will not be affected by the remap. 

## Prerequisities
* Install Git and GNOME extensions `sudo <your-package-manager> install git gnome-shell-extensions`.
* Install Rust `curl https://sh.rustup.rs -sSf | sh`. 
* Restart GNOME Shell `killall -3 gnome-shell`.

## Installation
1. Make sure you are running **Wayland** display server. Logout from your session. On the GNOME login screen click ⚙ icon on the bottom right. Select `GNOME` (defaults to Wayland). Log in.
2. Check out thie repository run `install.sh` script in Terminal. Script will ask for administrator password.

```
cd ~/Downloads
git clone https://github.com/petrstepanov/gnome-macos-remap-wayland
cd gnome-macos-remap-wayland
chmod +x ./install.sh
sh ./install.sh
```

3. Restart your computer.

## How to uninstall

1. If repository was removed, check it out again. Navigate into the program directory in Terminal and run:
```
chmod +x ./uninstall.sh
sh uninstall.sh
```

2. Restart your computer.

## Logbook

`May 23, 2021` • Moving to [xRemap](https://github.com/k0kubun/xremap) functionality instead.

`Dec 13, 2021` • First commit, testing out the [Key Mapper](https://github.com/sezanzeb/key-mapper).

