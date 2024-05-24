# Gnome → macOS Keyboard Remap for Wayland

This keyboard remap is based on the [xRemap](https://github.com/k0kubun/xremap) functionality and works under Xord and Wayland.

![Gnome macOS Remap Icon](./resources/gnome-macos-remap-wayland.png#gh-light-mode-only)
![Gnome macOS Remap Icon](./resources/gnome-macos-remap-wayland-dark.png#gh-dark-mode-only)

## How does it work?
Script doenloads the latest version of the `xremap` remapper for your architecture. Configuration file `config.yaml` contains majority of the remapping instructions. On top of that the default GNOME shell and Mutter keybindings are modified. A systemd service is created and enabled for a particular user. Therefore after the install other users on the system will not be affected by the remap. 

## Prerequisities
* Install Git and GNOME extensions `sudo <your-package-manager> install git gnome-shell-extensions`.

## Installation
1. Make sure you are running **Wayland** display server. Logout from your session. On the GNOME login screen click ⚙ icon on the bottom right. Select `GNOME` (defaults to Wayland). Log in.
2. Check out this repository run `install.sh` script in Terminal. Script will ask for administrator password.

```
cd ~/Downloads
git clone https://github.com/petrstepanov/gnome-macos-remap-wayland
cd gnome-macos-remap-wayland
chmod +x ./install.sh
./install.sh
```

3. Install and enable [this GNOME extension](https://extensions.gnome.org/extension/5060/xremap/).
4. Restart your computer.

## How to uninstall

1. If repository was removed, check it out again. Navigate into the program directory in Terminal and run:
```
chmod +x ./uninstall.sh
./uninstall.sh
```

2. Restart your computer.

## Logbook

`May 24, 2024` • Added keybindings for [GNOME Console](https://apps.gnome.org/Console/) app.

`Oct 01, 2023` • [Blocker issue](https://github.com/k0kubun/xremap/issues/100) is resolved. Repository is ready for testing.

`May 23, 2021` • Moving to [xRemap](https://github.com/k0kubun/xremap) functionality instead.

`Dec 13, 2021` • First commit, testing out the [Key Mapper](https://github.com/sezanzeb/key-mapper).
