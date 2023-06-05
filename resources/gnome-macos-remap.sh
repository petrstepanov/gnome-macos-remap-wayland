#!/bin/bash

xhost +SI:localuser:root
pkexec --user root xremap /usr/local/share/gnome-macos-remap/config.yml
