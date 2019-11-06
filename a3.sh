#!/bin/bash

sudo pacman -S xdg-user-dirs --noconfirm
xdg-user-dirs-update
pacman -S git rxvt-unicode f2fs-tools dosfstools ntfs-3g alsa-lib alsa-utils file-roller p7zip unrar gvfs aspell-ru pulseaudio pavucontrol --noconfirm

sudo pacman -S git 
git clone http:/aur.archlinux.org/yay.git
cd yay
makepkg -si

sudo yay -S ly-git --noconfirm
echo '2'
echo
systemctl enable ly