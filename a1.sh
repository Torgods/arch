#!/bin/bash

loadkeys ru
setfont cyr-sun16
timedatectl set-ntp true

echo "Если размечали диск только на один раздел "
echo "то нажмите (1)"
echo "Если на 2 boot и root"
echo "то нажмите (2)"
echo "Если создовали оделные разделы под boot root и home"
echo "то нажмите (3)"
echo "Если содовали разделы boot root home и swap"
echo "то нажмине (4)"

read -p "Вводим нужное чесло:" var
if   [[ $var == 1 ]]; then
	echo "Форматирование и монтирование раздела например(a1) "
	read -p "Ведите литиру и № раздела :" disk1
	mkfs.ext4 /dev/sd$disk1 -L root
	mount /dev/sd$disk2 /mnt
elif [[ $var == 2 ]]; then
	echo "Форматирование и монтирование разделов "
	read -p "Ведите литиру и № раздела boot :" disk1
	read -p "Ведите литиру и № раздела root :" disk2
	mkfs.ext2 /dev/sd$disk1 -L boot
	mkfs.ext4 /dev/sd$disk2 -L root
	mount /dev/sd$disk2 /mnt
	mkdir /mnt/boot
elif [[ $var == 3 ]]; then
	echo "Форматирование и монтирование разделов например(a1)"
	read -p "Ведите литиру и № раздела boot :" disk1
	read -p "Ведите литиру и № раздела root :" disk2
	read -p "Ведите литиру и № раздела home :" disk3
	mkfs.ext2 /dev/sd$disk1 -L boot
	mkfs.ext4 /dev/sd$disk2 -L root
	mkfs.ext4 /dev/sd$disk3 -L home
	mount /dev/sd$disk2 /mnt
	mkdir /mnt/{boot,home}
	mount /dev/sd$disk1 /mnt/boot
	mount /dev/sd$disk3 /mnt/home
elif [[ $var == 4 ]]; then
	echo "Форматирование и монтирование разделов например(a1)"
	read -p "Ведите литиру и № раздела boot :" disk1
	read -p "Ведите литиру и № раздела root :" disk2
	read -p "Ведите литиру и № раздела home :" disk3
	read -p "Ведите литиру и № раздела swap :" disk4
	mkfs.ext2 /dev/sd$disk1 -L boot
	mkfs.ext4 /dev/sd$disk2 -L root
	mkfs.ext4 /dev/sd$disk3 -L home
	mkswap /dev/sd$disk4 -L swap
	mount /dev/sd$disk2 /mnt
	mkdir /mnt/{boot,home}
	mount /dev/sd$disk1 /mnt/boot
	mount /dev/sd$disk3 /mnt/home
	swapon /dev/sd$disk4
fi

echo "Установка зеркала yandex"
echo "Server = http://mirror.yandex.ru/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

echo "Установка базовых пакетов"
pacstrap /mnt base base-devel

echo "Генерация таблици fstab"
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt

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