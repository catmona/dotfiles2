
# step-by-step installation

Instructions for making a replica of my set-up!  




## Archinstall

TODO - iwctl command

After connecting to wifi or ethernet, run archinstall with the following settings applied


 ![image](https://github.com/catmona/dotfiles2/assets/30540400/4b01da5e-06da-4798-afa9-a1ac282e2161)

  - Disk Configuration: BTRFS
  - Profile: Hyprland Desktop
  - Additional Packages: linux-firmware-marvell (if using surface laptop)
## nmcli, zsh, yay 

Once you login through sddm the first thing we need to do is get connected to the internet.

```bash
  sudo systemctl enable --now NetworkManager
  sudo nmcli --ask dev wifi connect "ssid"
  ping google.com
```

Install git
```bash
sudo pacman -S git
```

Now install yay for access to the AUR
```bash
cd /opt
sudo git clone https://aur.archlinux.org/yay-git.git
sudo chown -R user:user ./yay-git
cd yay-git
makepkg -si
```

Run yay to synch databases and install updates
```bash
yay
```

Now install Zsh
```bash
sudo pacman -S zsh
chsh -s $(which zsh)
```

Close and reopen your terminal, choose anything when it asks you to setup your .zshrc - we'll replace it with the one from this repo later anyways.


Now Install OhMyZsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
## btrfs, snapper, and pacman hooks

First off we need a GUI authentication agent. 

```bash
sudo pacman -S polkit-gnome
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
```

Now install snapper

```bash
sudo pacman -S snapper
```

Delete default /.snapshots subvolume so snapper can create its own without throwing a fit
```bash
    sudo umount /.snapshots
    sudo rm -rf /.snapshots
    sudo snapper -c root create-config /
    sudo btrfs subvolume delete /.snapshots
```

Now install pac-snap-grub, which will automatically create snapshots whenever you run pacman and add them to a grub recovery menu.

```bash
yay -S snap-pac-grub
sudo nano /etc/mkinitcpio.conf
```

add `grub-btrfs-overlayfs` to the end of the hooks array, so it looks like this:
```bash
# HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck grub-btrfs-overlayfs)
```

now run mkinitpcio to apply your changes. this will make snapshots act like a live cd so that changes are saved in RAM. 
```bash
sudo mkinitcpio -P
```


Now install btrfs-assistant to have a GUI for snapper and btrfs operations
```bash
yay -S btrfs-assistant
mkdir ~/.local/share/applications
sudo cp /usr/share/applications/btrfs-assistant.desktop ~/.local/share/applications
sudo nano ~/.local/share/applications/btrfs-assistant.desktop
```

change the "exec" line to `Exec=env QT_QPA_PLATFORM=wayland btrfs-assistant-launcher`

now run btrfs assistant and make a manual snapshot. You can change your config settings now too, like setting a max # of snapshots to keep and turning off timeline.
```bash
QT_QPA_PLATFORM=wayland btrfs-assistant-launcher
```
![image](https://github.com/catmona/dotfiles2/assets/30540400/647193e4-17cc-4691-81ed-50dfd0dac6bb)

test snapper by installing cowsay
```bash
sudo pacman -S cowsay
```

now restart, and on the grub menu select Arch Snapshots, and try to load the snapshot from before you installed cowsay. If it works, then yay! snapshots work. Reset again and load up your regular machine.

As a final piece of defense, install informant to give you news about manual intervention straight from the arch wiki whenever you run pacman.

```bash
yay -S informant
sudo informant read
```



## Set up git and github ssh


First generate a new ssh key for this machine
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Now add the same ssh key to your guthub account
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
```bash
cat ~/.ssh/id_ed25519
```

copy your key, head to https://github.com/settings/keys, and add your key to your profile

Now add your github email and name to this machine
```bash
git config --global user.email ""
git config --global user.name ""
```
## Clone this repo

If you're me, do this:

```bash
cd 
git clone git@github.com:catmona/dotfiles2.git
```
or if you're not me, then do this:
```bash
cd "whatever directory you keep files like this"
git clone https://github.com/catmona/dotfiles2.git 
```

Now install Stow to manage your dotfiles
```bash
sudo pacman -S stow
```
## Firefox

I use Firefox Nightly with a customized Cascade theme for a oneline look, and betterfox for my user.js, as well as NextDNS.

Download Firefox Nightly - skip this and just `sudo pacman -S firefox` if you'd rather be on stable.
```bash
sudo nano /etc/pacman.conf
```

add the following to the bottom:
```bash
[heftig]
SigLevel = Optional
Server = https://pkgbuild.com/~heftig/repo/$arch
```

now install Firefox Nightly
```bash
sudo pacman -Syyu
sudo pacman -S firefox-nightly
```

Sign in to firefox sync to sync your bookmarks, passwords, extensions, etc. I recommend installing UBlock Origin if you don't have it already.

Now for the annoying part of setting up firefox.
 - Go to `about:profiles`
 - Open the root folder of your active profile
 - Alternatively, find the default profile by using `ls` in `~/.mozilla/firefox/`

```bash
ln -s ~/dotfiles2/firefox/chrome
ln -s ~/dotfiles2/firefox/user.js
```


## VSCode

Install Code from pacman, as opposed to from the AUR, to prevent long build times on AUR updates.

```bash
sudo pacman -S code
```

Now install the marketplace and features AUR packages

```bash
yay -S code-marketplace code-features
```

Now open vscode, click the lil person in the bottom left, turn on settings sync, and sign in to get your extensions and settings and themes.
## I have so much RAM

You have so much RAM! Let's use it to speed up linux.

### Firefox
```bash
sudo pacman -S profile-sync-daemon
cd dotfiles2 && stow profile-sync-daemon
psd
psd
```

now enable overlayfs functionality for your user
```bash
sudo nano /etc/sudoers
```

add the following line to the end of the file: `user ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper`

```bash
systemctl --user enable --now psd
```

Moving cache to RAM - 
https://easylinuxtipsproject.blogspot.com/p/ssd.html?m=1#ID9.1

### Preload Applications
```bash
yay -S preload
sudo systemctl enable --now preload
```
## Download some extra packages

There's a ton of packages that aren't installed by default that you probably want.

```bash
sudo pacman -S wget
```