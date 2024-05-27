#!/bin/bash

gsettings set org.gnome.desktop.wm.keybindings show-desktop "[]"
xdotool key ctrl+d

sleep 2
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Control>d']"
