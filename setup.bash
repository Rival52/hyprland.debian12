# Author  : ONJANIAINA Henintsoa Stephana
# Created : 19/03/24 11:12:12
# Repo : henintsoa98/hyprland.debian12
# File : setup.bash

# ROOT CHECKER
if [ $(id -u) -eq 0 ]; then
	echo "Don't run as root, this only need sudo capability of current user"
	exit
fi

# SUDO CHECKER
if [[ $(id | egrep -v sudo) ]]; then
	echo "User not in sudo, run :"
	echo "su -c \"bash sudo.bash\""
	exit
fi

# INIT COLOR
source BIN/color

# UNINSTALL
if [[ "$1" == "uninstall" ]]; then
	echo -e "${BRed}+ Uninstall ...${Reset}"
	{
		cd SOURCE
		cd hyprland-source
		sudo make uninstall
		cd ../
		sudo rm -rf hyprland-source

		cd libdisplay-info-0.1.1
		cd build
		sudo ninja uninstall
		cd ../..
		sudo rm -rf libdisplay-info-0.1.1

		cd wayland-protocols-1.31
		cd build
		sudo ninja uninstall
		cd ../..
		sudo rm -rf wayland-protocols-1.31

		cd wayland-1.22.0
		cd build
		sudo ninja uninstall
		cd ../..
		sudo rm -rf wayland-1.22.0
	} > /dev/null
	echo -e "${BRed}+ Uninstall finished.${Reset}"
	exit
fi

# INSTALL DEPENDANCIES
echo -e "${BRed}+ Install dependancies ...${Reset}"
sudo apt install meson wget build-essential ninja-build cmake-extras cmake gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev libvulkan-volk-dev vulkan-validationlayers-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 libegl1-mesa-dev glslang-tools libinput-bin libinput-dev libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev xdg-desktop-portal-wlr hwdata libgbm-dev libpango1.0-dev xwayland edid-decode

# wifi modem in CLI
sudo cp BIN/* /usr/local/bin
sudo chmod +x /usr/local/bin/{wifi,modem,color}
sudo apt install -y network-manager iw wireless-tools


# EXTRACT SOURCE
echo -e "${BRed}+ Extracting ...${Reset}"
{
	cd SOURCE
	sudo rm -rf hyprland-source/ libdisplay-info-0.1.1/ wayland-1.22.0/ wayland-protocols-1.31/
	tar -xJf libdisplay-info-0.1.1.tar.xz
	tar -xzf source-v0.24.1.tar.gz
	tar -xJf wayland-1.22.0.tar.xz
	tar -xJf wayland-protocols-1.31.tar.xz
} > /dev/null

# WARNING
echo -e "${BPurple}BUILD and INSTALL proccess${Reset}"
echo -e "${BRed}only errors will be printed to make debug easier if error appears when launching Hyprland${Reset}"
sleep 3

# INSTALLING
echo -e "${BYellow}+ Build & install wayland ...${Reset}"
{
	cd wayland-1.22.0
	mkdir build
	cd build
	meson setup .. --prefix=/usr --buildtype=release -Ddocumentation=false
	ninja
	sudo ninja install
	cd ../..
} > /dev/null

echo -e "${BYellow}+ Build & install wayland-protocols ...${Reset}"
{
	cd wayland-protocols-1.31
	mkdir build
	cd build
	meson setup --prefix=/usr --buildtype=release
	ninja
	sudo ninja install
	cd ../..
} > /dev/null

echo -e "${BYellow}+ Build & install libdisplay-info ...${Reset}"
{
	cd libdisplay-info-0.1.1/
	mkdir build
	cd build
	meson setup --prefix=/usr --buildtype=release
	ninja
	sudo ninja install
	cd ../..
} > /dev/null

echo -e "${BYellow}+ Build & install Hyprland ...${Reset}"
{
	chmod a+rw hyprland-source
	cd hyprland-source/
	sed -i 's/\/usr\/local/\/usr/g' config.mk
	sudo make install
	cd ../..
} > /dev/null

# CONFIG
mkdir -p $HOME/.config/hypr
mkdir -p $HOME/.config/xkb/rules
mkdir -p $HOME/.config/xkb/symbols
cp CONFIG/hyprland.conf $HOME/.config/hypr/
cp CONFIG/evdev $HOME/.config/rules/
cp CONFIG/ctrl $HOME/.config/symbols/

# AUTOLOGIN ON TTY
echo -ne "${BRed}Autologin [from debian server only] : (y) / (n) ? ${Reset}"
read CHOICE
if [[ "$CHOICE" == "y" ]]
then
	sudo su -c "sed -i \"s#^ExecStart#ExecStart=-/sbin/agetty -a $USER --noclear %I \$TERM\n\#ExecStart#\" /etc/systemd/system/getty.target.wants/getty@tty1.service"
fi

# INSTALL OTHER PACKAGE
echo -ne "${BPurple}Want install some software that fit on ${BYellow}Hyprland ${BPurple}and ${BYellow}Wayland? ${BWhite}[RECOMMANDED](yn) : ${BRed}"

read ANS
echo -e ${Reset}
case $ANS in 
	""|"Y"|"y")
		mkdir UTILITY/
		cd UTILITY/
		git clone --depth 1 https://github.com/henintsoa98/dotfiles.debian12
		cd dotfiles.debian12
		bash setup.bash;;
esac
