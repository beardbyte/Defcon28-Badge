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
while getopts ":a" opt; do
  case $opt in
    a)
      echo "-a was triggered!" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


###############################
#### Setup
###############################
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
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
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && echo $grn Net Connection Detected! $white || echo $red Error Cannont Connect to Net T_T $white


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
echo "$red Installing fbcp-ili9341 Driver $white"
cd fbcp-ili9341
mkdir build
cd build
cmake -DADAFRUIT_HX8357D_PITFT=ON -DSTATISTICS=0 -DSPI_BUS_CLOCK_DIVISOR=8 ..
make -j
echo ""

###############################
#### System Setup Stuff
###############################
# force_turbo=1 
echo "Checking /etc/rc.local"
if ! grep -q fbcp-ili9341 /etc/rc.local; then
	 echo "$red Updating rc.local $white"
	 sudo sed -i -e '$asudo /home/pi/Defcon28-Badge/fbcp-ili9341/build/fbcp-ili9341 &' /etc/rc.local
fi
echo ""

#########################################
#### So Long And Thanks For All The Fish!
printf -- '\n';
exit 0;
