#!/bin/bash

####################################################
##
##  ___   ___ _____
## |   \ / __|_  (_)__ _
## | |) | (__ / /| / _` |
## |___/ \___/___|_\__,_|
##
## DCZia 2020 PiBadge Mini Build Scrip
## 
## Script by @lithochasm & @toasty
## Shoutout to the DCZia Crew
##
##
##
##
####################################################


###############################
#### Get Command Line Options
###############################
while getopts "dhD:" opt; do
case $opt in
    D)
      echo "-D was triggered, Parameter: $OPTARG" >&2
      DISPVAR="${OPTARG}"
      ;;
    d) # debug
      shopt -o -s xtrace
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument. Please specify display type" >&2
      exit 1
      ;;
    h)
      echo "Halp: -D DISPLAY_VAR " >&2
      echo "Currently supported: " >&2
      echo "  WAVESHARE - Waveshare ST7735S (default)" >&2
      echo "  HX8357D - Adafruit PiTFT 3.5" >&2
      echo "  ILI9341 - Adafruit 2.8 TFT" >&2
      exit 1
      ;;
  esac
done

# default case if no options
if (( OPTIND == 1 )); then
   echo "Default option"
   DISPVAR="WAVESHARE"
fi

###############################
#### Setup
###############################
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
# mag=$'\e[1;35m'
# cyn=$'\e[1;36m'
white=$'\e[0m'


clear
echo " $blu"
echo "  ___   ___ _____"
echo " |   \\ / __|_  (_)__ _"
echo " | |) | (__ / /| / _\` | "
echo " |___/ \\___/___|_\\__,_| "
echo " $red DCzia Badge Setup v1 $white"
echo ""

###############################
#### Check if we have internet
###############################
ping -q -w 1 -c 1 "$(ip r | grep default | cut -d ' ' -f 3)" > /dev/null && echo "$grn Net Connection Detected! $white" || echo "$red Error Cannont Connect to Net T_T $white"


###############################
#### Install base packages
###############################
echo "$grn Installing Software $white"
echo ""

sudo apt-get install omxplayer cmake libbsd-dev vim git
git clone https://github.com/juj/fbcp-ili9341.git
echo ""

###############################
#### Setup TFT Screen Drivers
###############################
### NEED TO CHECK CMD LINE OPTION AND FORK HERE FOR EACH SCREEN TYPE
### Adafruit PiTFT 3.5

cd fbcp-ili9341 || exit
mkdir build
cd build || exit
if [[ "${DISPVAR}" == "HX8357D" ]] ; then
    DISPTYPE="-DADAFRUIT_HX8357D_PITFT=ON"
    echo "$red Installing fbcp-ili9341 Driver for PiTFT 3.5$white"
    cmake "${DISPTYPE}" -DDISPLAY_ROTATE_180_DEGREES=ON -DSTATISTICS=0 -DSPI_BUS_CLOCK_DIVISOR=6 ..
elif [[ "${DISPVAR}" == "ILI9341" ]] ; then
    DISPTYPE="-DADAFRUIT_ILI9341_PITFT=ON"
    echo "$red Installing fbcp-ili9341 Driver for Adafruit 2.8$white"
    cmake "${DISPTYPE}" -DDISPLAY_ROTATE_180_DEGREES=ON -DSTATISTICS=0 -DSPI_BUS_CLOCK_DIVISOR=6 ..
elif [[ "${DISPVAR}" == "WAVESHARE" ]] ; then
    DISPTYPE="-DWAVESHARE_ST7735S_HAT=ON"
    echo "$red Installing fbcp-ili9341 Driver for Waveshare 1.44$white"
    cmake "${DISPTYPE}" -DDISPLAY_ROTATE_180_DEGREES=OFF -DSTATISTICS=0 -DSPI_BUS_CLOCK_DIVISOR=14 -DDISPLAY_CROPPED_INSTEAD_OF_SCALING=OFF -DDISPLAY_BREAK_ASPECT_RATIO_WHEN_SCALING=ON ..
fi    
    make -j
echo ""

###############################
#### System Setup Stuff
###############################
echo "$grn Checking /etc/rc.local $white"
if ! grep -q fbcp-ili9341 /etc/rc.local; then
	 echo "$red Updating rc.local - Enabling fbcp-ili9341 $white"
	 sudo sed -i -e '$asudo /home/pi/Defcon28-Badge/fbcp-ili9341/build/fbcp-ili9341 &' /etc/rc.local

 else
	 echo "$blu fbcp-ili9341 driver already enabled $white"
fi

if ! grep -q autoplay /etc/rc.local; then
         echo "$red Updating rc.local - Enabling Autoplay $white"
         sudo sed -i -e '$a /home/pi/Defcon28-Badge/autoplay.sh ALL' /etc/rc.local
 else 
	 echo "$blu Autoplay already enabled $white"
fi
echo ""

echo "$grn Checking for DCZia Boot Settings $white"
if ! grep -q "DCZia_Hackz" /boot/config.txt; then
        echo "$red Updating /boot/config.txt - Enabling Speed Hacks $white"
        #sudo sed -i -e '$aforce_turbo=1' /boot/config.txt
	#sudo sed '/console/ s/$/ quiet loglevel=3 console=tty3/' /boot/cmdline.txt
        cat /home/pi/Defcon28-Badge/boot_hacks | sudo tee -a /boot/config.txt > /dev/null
	sudo systemctl disable ntp.service
	sudo systemctl disable dphys-swapfile.service
	sudo systemctl disable keyboard-setup.service
	sudo systemctl disable apt-daily.service
	sudo systemctl disable wifi-country.service
	sudo systemctl disable hciuart.service
	sudo systemctl disable raspi-config.service
	sudo systemctl disable avahi-daemon.service
	#sudo systemctl disable triggerhappy.service
        sudo systemctl disable rsyslog.service
	sudo systemctl disable systemd-timesyncd.service
else
	echo "$blu DCZIa Speed Hacks Enabled $white" 
fi

if ! grep -q "quiet" /boot/cmdline.txt; then

	echo "$red Setting up console $white"
	echo "Set up main console turn on"
    	if ! grep -q 'fbcon=map:10 fbcon=font:VGA8x8' /boot/cmdline.txt; then
        	echo "Updating /boot/cmdline.txt"
        	sed -i 's/rootwait/rootwait fbcon=map:10 fbcon=font:VGA8x8/g' "/boot/cmdline.txt"
    	else
        	echo "/boot/cmdline.txt already updated"
    	fi

	sudo sed '/console/ s/$/ quiet loglevel=3 console=tty3/' /boot/cmdline.txt

fi

echo ""

#########################################
#### So Long And Thanks For All The Fish!
printf -- '\n';
exit 0;
