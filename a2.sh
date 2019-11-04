#!/bin/bash

read -p "Ведите имя пользователя: " username
read -p "Ведите иня компютера: " hostname
read -p "Ведите ваш регион например (Europe) : " region
read -p "Ведите ваш город например (Moscow) : " city

echo $hostname > /etc/hostname

ln -svf /usr/share/zoneinfo/$region/$city /etc/localtime
echo "Добавляем Русскую локаль"
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen

echo "Обновляем текущию локаль"
locale-gen

echo "устанавливаем язык системы"
read -p "Ведите (ru) или (en) : " lang
if [[ $lang == ru ]]; then
	echo 'LANG="ru_RU.UTF-8"' > /etc/locale.conf
	echo 'KEYMAP=ru' >> /etc/vconsole.conf
	echo 'FONT=cyr-sun16' >> /etc/vconsole.conf
elif [[ $lang == en ]]; then
	echo 'LANG="en_US.UTF-8"' > /etc/locale.conf
fi
echo "Создаём загрузочный диск RAM"
pacman -Sy mkinitcpio linux --noconfirm
mkinitcpio -p linux

read -p "Укажите литеру вашего диска например (a) :" disk
echo " Устанавливаем загрузчик grub "
 
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sd$disk
grub-mkconfig -o /boot/grub/grub.cfg

echo "Ставим программы Wi-fi"
pacman -S dialog wpa_supplicant --noconfirm 
echo 'Ставим сеть'
pacman -S networkmanager network-manager-applet ppp --noconfirm
systemctl enable NetworkManager

echo "Создаем root пароль"
passwd

useradd -m -g users -G wheel -s /bin/bash $username
echo "Устанавливаем пароль пользователя"
passwd $username

echo 'Устанавливаем SUDO'
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
pacman -Syy

echo "Базавая установка Archlinux завершина"
echo

read -p "Будим продолжать (Y N)? " yn
if [[ $yn == n ]]; then
 	echo "перезагрузите систему командой reboot "
 	exit
 elif [[ $yn == y ]]; then
 	echo "Будут установлены Xserver и драйвера"
 	echo "куда будем утанавливать PC или VB "
fi
read -p "PC 1 VB 2 " vmset
if [[ $vmset == 1 ]]; then
	pacman -S xorg-server xorg-drivers xorg-xinit --noconfirm
elif [[ $vmset == 2 ]]; then
	pacman -S xorg-server xorg-drivers xorg-xinit virtualbox-guest-utils --noconfirm
fi
echo 'что будем исползовать в Xfce4(1) i3(2) '
read -p "ввщдим 1 или 2" gui 
if [[ $gui == 1 ]]; then
	pacman -S xfce4 xfce4-goodies --noconfirm
elif [[ condition ]]; then
		pacman -S i3 i3-status dmenu rxvt-unicode
fi



