# Hello Bros Welcome
printf '\033c'
echo "Welcome to archy install bros"
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Get ready to create partition"
echo "Enter the drive (like /dev/sda): "
read drive
cfdisk $drive 
echo "Enter the linux partition (like /dev/sda6): "
read partition
mkfs.ext4 $partition 
mount $partition /mnt
read -p "Did you also create efi partition? [y/n]" ansefi
if [[ $ansefi = y ]] ; then
  echo "Enter EFI partition (like /dev/sda4): "
  read efipartition
  mkfs.vfat -F 32 $efipartition
  mount --mkdir $efiparition /mnt/boot
fi
read -p "Did you also create swap partition? [y/n]" ansswap
if [[ $ansswap = y ]] ; then
  echo "Enter swap partition (like /dev/sda5): "
  read swappartition
  mkswap $swappartition
  swapon $swappartition
fi
pacstrap /mnt base base-devel linux linux-firmware linux-headers vim nano intel-ucode networkmanager network-manager-applet wireless_tools bluez bluez-utils git
genfstab -U /mnt >> /mnt/etc/fstab
sed '1,/^#part2$/d' `basename $0` > /mnt/install2.sh
chmod +x /mnt/install2.sh
arch-chroot /mnt ./install2.sh
exit 

#part2
printf '\033c'
ln -sf /usr/share/zoneinfo/Asia/Kathmandu /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "Hostname: "
read hostname
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
passwd
echo "Enter Username: "
read username
passwd $username
usermod -aG wheel,storage,power,audio $username
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
pacman --noconfirm -S grub efibootmgr os-prober ntfs-3g
read -p "Did you dual boot win and linux? [y/n]" answin
lsblk
if [[ $ansswap = y ]] ; then
  echo "Enter windows boot partition (like /dev/sda1): "
  read windowpartiton
  mkdir /mnt/windows/
  mount $efipartition /mnt/windows/
fi
echo "Enter EFI partition (like /dev/sda4): " 
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi 
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop \
     noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
     fzf man-db xwallpaper python-pywal unclutter xclip maim \
     zip unzip unrar p7zip xdotool papirus-icon-theme brightnessctl  \
     dosfstools git sxhkd zsh pipewire pipewire-pulse \
     arc-gtk-theme rsync qutebrowser dash \
     xcompmgr picom ripgrep libnotify dunst slock jq aria2 cowsay \
     dhcpcd network-manager-applet wireless_tools \
     wpa_supplicant rsync pamixer mpd ncmpcpp \
     zsh-syntax-highlighting xdg-user-dirs libconfig \
     bluez bluez-utils

systemctl enable NetworkManager bluetooth 
rm /bin/sh
ln -s dash /bin/sh
echo "Pre-Installation Finish Reboot now"
ai3_path=/home/$username/install3.sh
sed '1,/^#part3$/d' install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit 

#part3
printf '\033c'
cd $HOME
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/Rustywriter/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
# dwm: Window Manager
git clone --depth=1 https://github.com/Rustywriter/dwm.git ~/.local/src/dwm
sudo make -C ~/.local/src/dwm install

# st: Terminal
git clone --depth=1 https://github.com/Rustywriter/st.git ~/.local/src/st
sudo make -C ~/.local/src/st install

# dmenu: Program Menu
git clone --depth=1 https://github.com/Rustywriter/dmenu.git ~/.local/src/dmenu
sudo make -C ~/.local/src/dmenu install

# dmenu: Dmenu based Password Prompt
git clone --depth=1 https://github.com/ritze/pinentry-dmenu.git ~/.local/src/pinentry-dmenu
sudo make -C ~/.local/src/pinentry-dmenu clean install

# neovim setup
git clone --depth=1 https://github.com/Rustywriter/init.lua ~/.config/nvim

# yay: AUR helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -fsri
cd
yay -S libxft-bgra-git yt-dlp-drop-in helix neovim github-cli phinger-cursors fzf tmux qbittorrent
mkdir dl doc imp music pix vid code

ln -s ~/.config/x11/xinitrc .xinitrc
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
mv ~/.oh-my-zsh ~/.config/zsh/oh-my-zsh
rm ~/.zshrc ~/.zsh_history
ln -s ~/.config/zsh/zsh .zshrc
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dots config --local status.showUntrackedFiles no
exit
