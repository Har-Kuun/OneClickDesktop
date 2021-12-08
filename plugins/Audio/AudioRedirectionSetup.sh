#!/bin/bash
###########################################################################################
#    Audio Redirection Setup Script for OneClickDesktop                                   #
#    Written by shc (https://qing.su)                                                     #
#    Github link: https://github.com/Har-Kuun/OneClickDesktop                             #
#    Contact me: https://t.me/hsun94   E-mail: hi@qing.su                                 #
#                                                                                         #
#    This script is distributed in the hope that it will be                               #
#    useful, but ABSOLUTELY WITHOUT ANY WARRANTY.                                         #
#                                                                                         #
#    The author thanks c-energy for providing detailed                                    #
#    instructions on pulseaudio setup.                                                    #
#    https://c-nergy.be/blog/?p=16817                                                     #
#                                                                                         #
#    Thank you for using this script.                                                     #
###########################################################################################


exec > >(tee -i OneClickDesktop_AudioRedirection.log)
exec 2>&1

function check_OS
{
	if [ -f /etc/lsb-release ] ; then
		cat /etc/lsb-release | grep "DISTRIB_RELEASE=18." >/dev/null
		if [ $? = 0 ] ; then
			OS=bionic
		else
			cat /etc/lsb-release | grep "DISTRIB_RELEASE=20." >/dev/null
			if [ $? = 0 ] ; then
				OS=focal
			else
				say "Sorry, this script only supports Ubuntu 18/20, and Debian 10." red
				echo 
				exit 1
			fi
		fi
	elif [ -f /etc/debian_version ] ; then
		cat /etc/debian_version | grep "^10." >/dev/null
		if [ $? = 0 ] ; then
			OS=DEBIAN10
		else
			say "Sorry, this script only supports Ubuntu 18/20, and Debian 10." red
			echo 
			exit 1
		fi
	else
		say "Sorry, this script only supports Ubuntu 18/20, and Debian 10." red
		echo 
		exit 1
	fi
}

function say
{
#This function is a colored version of the built-in "echo."
#https://github.com/Har-Kuun/useful-shell-functions/blob/master/colored-echo.sh
	echo_content=$1
	case $2 in
		black | k ) colorf=0 ;;
		red | r ) colorf=1 ;;
		green | g ) colorf=2 ;;
		yellow | y ) colorf=3 ;;
		blue | b ) colorf=4 ;;
		magenta | m ) colorf=5 ;;
		cyan | c ) colorf=6 ;;
		white | w ) colorf=7 ;;
		* ) colorf=N ;;
	esac
	case $3 in
		black | k ) colorb=0 ;;
		red | r ) colorb=1 ;;
		green | g ) colorb=2 ;;
		yellow | y ) colorb=3 ;;
		blue | b ) colorb=4 ;;
		magenta | m ) colorb=5 ;;
		cyan | c ) colorb=6 ;;
		white | w ) colorb=7 ;;
		* ) colorb=N ;;
	esac
	if [ "x${colorf}" != "xN" ] ; then
		tput setaf $colorf
	fi
	if [ "x${colorb}" != "xN" ] ; then
		tput setab $colorb
	fi
	printf "${echo_content}" | sed -e "s/@B/$(tput bold)/g"
	tput sgr 0
	printf "\n"
}

function check_OneClickDesktop_installation
{
	ss -lnpt | grep xrdp > /dev/null
	if [ $? = 0 ] ; then
		ss -lnpt | grep guacd > /dev/null
		if [ $? = 0 ] ; then
			say @B"OneClickDesktop is installed and running." green
		else 
			say "OneClickDesktop seems to be installed, but not running!" red
			say @B"Please check your installation, then run this script again." yellow
			echo "Thank you!"
			exit 1
		fi
		echo 
	else
		say "OneClickDesktop is not installed, or not running!" red
		say @B"Please install OneClickDesktop first, then run this script again." yellow
		echo "Thank you!"
		exit 1
	fi
}

function display_license
{
	echo 
	echo '*******************************************************************'
	echo '*       Audio Redirection Setup Script for OneClickDesktop        *'
	echo '*       Version 0.0.1                                             *'
	echo '*       Author: shc (Har-Kuun) https://qing.su                    *'
	echo '*       https://github.com/Har-Kuun/OneClickDesktop               *'
	echo '*       Thank you for using this script.  E-mail: hi@qing.su      *'
	echo '*******************************************************************'
	echo 
}

function AudioRedirectionSetup_Ubuntu
{
	sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
	apt-get update -y
	apt-get install software-properties-common -y
	apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$OS' main restricted'
	apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$OS' restricted universe main multiverse'
	apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$OS'-updates restricted universe main multiverse'
	apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$OS'-backports main restricted universe multiverse'
	apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$OS'-security main restricted universe main multiverse'
	apt-get update -y
	apt-get install git libpulse-dev autoconf m4 intltool dpkg-dev libtool libsndfile-dev libcap-dev libjson-c-dev -y
	apt-get build-dep pulseaudio -y
	apt source pulseaudio
	pulsever=$(pulseaudio --version | awk '{print $2}')
	cd pulseaudio-$pulsever
	./configure
	if [ -f $CurrentDir/pulseaudio-$pulsever/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling pulseaudio now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, reboot, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
	cd pulseaudio-module-xrdp
	./bootstrap
	./configure PULSE_DIR="$CurrentDir/pulseaudio-$pulsever"
	if [ -f $CurrentDir/pulseaudio-$pulsever/pulseaudio-module-xrdp/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling pulseaudio-xrdp now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, reboot, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	make
	cd $CurrentDir/pulseaudio-$pulsever/pulseaudio-module-xrdp/src/.libs
	install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so
	install -t "/usr/lib/pulse-$pulsever/modules" -D -m 644 *.so
}

function AudioRedirectionSetup_Debian
{
	apt-get install git libpulse-dev autoconf m4 intltool dpkg-dev screen libtool libsndfile-dev libcap-dev libjson-c-dev -y
	apt-get build-dep pulseaudio -y
	apt source pulseaudio
	pulsever=$(pulseaudio --version | awk '{print $2}')
	cd pulseaudio-$pulsever
	./configure
	if [ -f $CurrentDir/pulseaudio-$pulsever/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling pulseaudio now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, reboot, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
	cd pulseaudio-module-xrdp
	./bootstrap
	./configure PULSE_DIR="$CurrentDir/pulseaudio-$pulsever"
	if [ -f $CurrentDir/pulseaudio-$pulsever/pulseaudio-module-xrdp/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling pulseaudio-xrdp now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, reboot, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	make
	cd $CurrentDir/pulseaudio-$pulsever/pulseaudio-module-xrdp/src/.libs
	install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so
	install -t "/usr/lib/pulse-$pulsever/modules" -D -m 644 *.so
}

function main
{
	display_license
	check_OS
	echo "This script is going to set up audio redirection on a VPS."
	say @B"You must have OneClickDesktop installed in xrdp mode on your VPS before running this script." yellow
	echo 
	say @B"Would you like to proceed? [Y/N]" yellow
	read confirm_installation
	if [ "x$confirm_installation" = "xY" ] || [ "x$confirm_installation" = "xy" ] ; then
		check_OneClickDesktop_installation
		CurrentDir=$(pwd)
		if [ "$OS" = "DEBIAN10" ] ; then
			AudioRedirectionSetup_Debian
		else
			AudioRedirectionSetup_Ubuntu
		fi
		echo
		say @B"Audio Redirection successfully set up!" green
		say @B"Please reboot, then visit https://github.com/Har-Kuun/OneClickDesktop/tree/master/plugins/Audio for next steps!" yellow
	fi
	echo 
	echo "Thank you for using this script written by https://qing.su!"
	echo "Have a nice day!"
}

###############################################################
#                                                             #
#               The main function starts here.                #
#                                                             #
###############################################################

main
exit 0
