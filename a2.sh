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

read -p "Укажите лителу вашего диска например (a) :" disk
echo " Устанавливаем загрузчик grub "
 
pacman -Syy
pacman -S grub --noconfirm 
grub-install /dev/sd$disk
grub-mkconfig -o /boot/grub/grub.cfg

echo "Ставим программы Wi-fi"
pacman -S dialog wpa_supplicant --noconfirm 

echo "Создаем root пароль"
passwd

useradd -m -g users -G wheel -s /bin/bash $username
echo "Устанавливаем пароль пользователя"
passwd $username

echo "Базавая установка Archlinux завершина "
exit
rebot