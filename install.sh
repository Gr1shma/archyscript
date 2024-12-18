# Hello Bros Welcome
printf '\033c'
echo "Welcome to archy install bros"
pacman --noconfirm -Sy archlinux-keyring
loadkeys us
timedatectl set-ntp true
lsblk
echo "Get ready to create partition"
echo "Enter the drive (like /dev/nvme0n1): "
read drive
cfdisk $drive
echo "Enter the linux partition (like /dev/nvme0n1p6): "
read partition
mkfs.ext4 $partition
mount $partition /mnt
read -p "Did you also create efi partition? [y/n]" ansefi
if [[ $ansefi = y ]] ; then
  echo "Enter EFI partition (like /dev/nvme0n1p5): "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi
read -p "Did you also create swap partition? [y/n]" ansswap
if [[ $ansswap = y ]] ; then
  echo "Enter swap partition (like /dev/nvme0n1p8): "
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
useradd -m $username
passwd $username
usermod -aG wheel,storage,power,audio $username
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
pacman --noconfirm -S grub efibootmgr os-prober ntfs-3g
lsblk
echo "Enter EFI partition (like /dev/nvme0n1p5): "
read efipartition
mkdir /boot/efi
mount $efipartition /boot/efi
read -p "Did you dual boot win and linux? [y/n]" answin
if [[ $answin = y ]] ; then
  echo "Enter windows boot partition (like /dev/nvme0n1p1): "
  read windowpartiton
  mkdir /mnt/windows/
  mount $efipartition /mnt/windows/
  echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
fi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg



pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight xorg-xprop \
     noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
     sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
     fzf man-db xwallpaper python-pywal unclutter xclip maim \
     zip unzip unrar p7zip xdotool papirus-icon-theme brightnessctl udisks2 \
     dosfstools git sxhkd zsh pipewire pipewire-pulse \
     arc-gtk-theme rsync qutebrowser dash \
     xcompmgr ripgrep libnotify dunst slock jq aria2 cowsay \
     dhcpcd network-manager-applet wireless_tools \
     wpa_supplicant rsync pamixer mpd ncmpcpp \
     zsh-syntax-highlighting xdg-user-dirs libconfig \
     bluez bluez-utils

systemctl enable NetworkManager bluetooth
rm /bin/sh
ln -s dash /bin/sh
echo "Pre-Installation Finish"
ai3_path=/home/$username/install3.sh
sed '1,/^#part3$/d' install2.sh > $ai3_path
chown $username:$username $ai3_path
chmod +x $ai3_path
su -c $ai3_path -s /bin/sh $username
exit

#part3
printf '\033c'
cd $HOME
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/Gr1shma/dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
# dwm: Window Manager
git clone --depth=1 https://github.com/Gr1shma/dwm.git ~/.local/src/dwm
sudo make -C ~/.local/src/dwm install

# st: Terminal
git clone --depth=1 https://github.com/Gr1shma/st.git ~/.local/src/st
sudo make -C ~/.local/src/st install

# dmenu: Program Menu
git clone --depth=1 https://github.com/Gr1shma/dmenu.git ~/.local/src/dmenu
sudo make -C ~/.local/src/dmenu install

# dmenu: Dmenu based Password Prompt
git clone --depth=1 https://github.com/ritze/pinentry-dmenu.git ~/.local/src/pinentry-dmenu
sudo make -C ~/.local/src/pinentry-dmenu clean install

# neovim setup
git clone --depth=1 https://github.com/Gr1shma/init.lua ~/.config/nvim

# yay: AUR helper
git clone https://aur.archlinux.org/yay.git ~/yay
cd yay
makepkg -fsri --noconfirm
cd
rm -rf ~/yay
yay -S --noconfirm libxft-bgra-git yt-dlp-drop-in helix neovim github-cli phinger-cursors fzf tmux qbittorrent firefox syncthing nvidia nvidia-utils nvidia-settings auto-cpufreq node-js yarn npm luarocks lua51 rofi thunar tumbler yazi postman-bin nsxiv btop pfetch jq lazygit tree ueberzugpp elixir zig

# rust install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --quiet -y

mkdir dl dox music pix vid code projects personal

ln -s ~/.config/x11/xinitrc .xinitrc
rm ~/.zshrc ~/.zsh_history
ln -s ~/.config/zsh/zsh .zshrc

alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dots config --local status.showUntrackedFiles no

echo "run install4.sh after reboot"
ai4_path=/home/$username/install4.sh
sed '1,/^#part4$/d' install3.sh > $ai4_path
exit

#part4
printf '\033c'
read -p "Is this predator? [y/n]" anspredator
if [[ $anspredator = y ]]; then
    echo "options snd-hda-intel dmic_detect=0" | tee -a /etc/modprobe.d/alsa-base.conf
    echo "blacklist snd_soc_skl" | tee -a /etc/modprobe.d/blacklist.conf
fi
read -p "Is this pc have keyboard? [y/n]" anskeyboard
if [[ $anskeyboard = y ]]; then
    echo "Section \"InputClass\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf 
    echo "    Identifier \"touchpad\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf 
    echo "    Driver \"libinput\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf 
    echo "    MatchIsTouchpad \"on\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf 
    echo "    Option \"Tapping\" \"on\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf 
    echo "    Option \"TappingButtonMap\" \"lmr\"" >> /etc/X11/xorg.conf.d/30-touchpad.conf
    echo "EndSection" >> /etc/X11/xorg.conf.d/30-touchpad.conf 
fi
read -p "Do you want to reboot now? [y/n]" ansreboot
if [[ $ansreboot = y ]]; then
    reboot
fi
rm -rf install3.sh
exit
