# Author  : ONJANIAINA Henintsoa Stephana
# Created : 19/03/24 17:34:28
# Repo : henintsoa98/hyprland.debian12
# File : sudo.bash

if [ $(id -u) -ne 0 ]; then
	echo "Root password"
	exec su -c "bash sudo.bash"
fi

/sbin/usermod -aG audio,video,sudo $(id -un 1000)

echo "Reboot your system or use newgrp if you are a pro"
echo -ne "${BRed}Reboot${Reset} now (yn) : ${BRed}"
read ANS
echo -e ${Reset}
case $ANS in
	""|"Y"|"y")
		/sbin/reboot;;
esac
