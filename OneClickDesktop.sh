#!/bin/bash
###########################################################################################
#    One-click Desktop & Browser Access Setup Script v0.2.0                               #
#    Written by shc (https://qing.su)                                                     #
#    Github link: https://github.com/Har-Kuun/OneClickDesktop                             #
#    Contact me: https://t.me/hsun94   E-mail: hi@qing.su                                 #
#                                                                                         #
#    This script is distributed in the hope that it will be                               #
#    useful, but ABSOLUTELY WITHOUT ANY WARRANTY.                                         #
#                                                                                         #
#    The author thanks LinuxBabe for providing detailed                                   #
#    instructions on Guacamole setup.                                                     #
#    https://www.linuxbabe.com/debian/apache-guacamole-remote-desktop-debian-10-buster    #
#                                                                                         #
#    Thank you for using this script.                                                     #
###########################################################################################


#You can change the Guacamole source file download link here.
#Check https://guacamole.apache.org/releases/ for the latest stable version.

GUACAMOLE_DOWNLOAD_LINK="https://mirrors.ocf.berkeley.edu/apache/guacamole/1.2.0/source/guacamole-server-1.2.0.tar.gz"
GUACAMOLE_VERSION="1.2.0"

#By default, this script only works on Ubuntu 18/20, Debian 10, and CentOS 7/8.
#You can disable the OS check switch below and tweak the code yourself to try to install it in other OS versions.
#Please do note that if you choose to use this script on OS other than Ubuntu 18/20, Debian 10, or CentOS 7/8, you might mess up your OS.  Please keep a backup of your server before installation.

OS_CHECK_ENABLED=ON




#########################################################################
#    Functions start here.                                              #
#    Do not change anything below unless you know what you are doing.   #
#########################################################################

exec > >(tee -i OneClickDesktop.log)
exec 2>&1

function check_OS
{
	if [ -f /etc/lsb-release ] ; then
		cat /etc/lsb-release | grep "DISTRIB_RELEASE=18." >/dev/null
		if [ $? = 0 ] ; then
			OS=UBUNTU18
		else
			cat /etc/lsb-release | grep "DISTRIB_RELEASE=20." >/dev/null
			if [ $? = 0 ] ; then
				OS=UBUNTU20
			else
				say "Sorry, this script only supports Ubuntu 20, Debian 10, and CentOS 7/8." red
				echo 
				exit 1
			fi
		fi
	elif [ -f /etc/debian_version ] ; then
		cat /etc/debian_version | grep "^10." >/dev/null
		if [ $? = 0 ] ; then
			OS=DEBIAN10
		else
			say "Sorry, this script only supports Ubuntu 20, Debian 10, and CentOS 7/8." red
			echo 
			exit 1
		fi
	elif [ -f /etc/redhat-release ] ; then
		cat /etc/redhat-release | grep " 8." >/dev/null
		if [ $? = 0 ] ; then
			OS=CENTOS8
			say @B"Support of CentOS 8 is experimental.  Please report bugs." yellow
			say @B"Please try disabling selinux or firewalld if you cannot visit your desktop." yellow
			echo 
		else
			cat /etc/redhat-release | grep " 7." >/dev/null
			if [ $? = 0 ] ; then
				OS=CENTOS7
				say @B"Support of CentOS 7 is experimental.  Please report bugs." yellow
				say @B"Please try disabling selinux or firewalld if you cannot visit your desktop." yellow
				echo 
			else
				say "Sorry, this script only supports Ubuntu 20, Debian 10, and CentOS 7/8." red
				echo
				exit 1
			fi
		fi
	else
		say "Sorry, this script only supports Ubuntu 20, Debian 10, and CentOS 7/8." red
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

function determine_system_variables
{
	CurrentUser="$(id -u -n)"
	CurrentDir=$(pwd)
	HomeDir=$HOME
}

function get_user_options
{
	echo 
	say @B"Please input your Guacamole username:" yellow
	read guacamole_username
	echo 
	say @B"Please input your Guacamole password:" yellow
	read guacamole_password_prehash
	read guacamole_password_md5 <<< $(echo -n $guacamole_password_prehash | md5sum | awk '{print $1}')
	echo 
	if [ "x$OS" != "xCENTOS8" ] && [ "x$OS" != "xCENTOS7" ] ; then
		say @B"Would you like Guacamole to connect to the server desktop through RDP or VNC?" yellow
		say @B"Input 1 for RDP, or 2 for VNC.  If you have no idea what's this, please choose 1." yellow
		read choice_rdpvnc
	else 
		say @B"Guacamole will use RDP to communicate with server desktop." yellow
		choice_rdpvnc=1
	fi
	echo 
	if [ $choice_rdpvnc = 1 ] ; then
		say @B"Please choose a screen resolution." yellow
		echo "Choose 1 for 1280x800 (default), 2 to fit your local screen, or 3 to manually configure RDP screen resolution."
		read rdp_resolution_options
		if [ $rdp_resolution_options = 2 ] ; then
			set_rdp_resolution=0;
		else
			set_rdp_resolution=1;
			if [ $rdp_resolution_options = 3 ] ; then
				echo 
				echo "Please type in screen width (default is 1280):"
				read rdp_screen_width_input
				echo "Please type in screen height (default is 800):"
				read rdp_screen_height_input
				if [ $rdp_screen_width_input -gt 1 ] && [ $rdp_screen_height_input -gt 1 ] ; then
					rdp_screen_width=$rdp_screen_width_input
					rdp_screen_height=$rdp_screen_height_input
				else
					say "Invalid screen resolution input." red
					echo 
					exit 1
				fi
			else
				rdp_screen_width=1280
				rdp_screen_height=800
			fi
		fi
		say @B"Screen resolution successfully configured." green
	else
		echo 
		while [ ${#vnc_password} != 8 ] ; do
			say @B"Please input your 8-character VNC password:" yellow
		read vnc_password
		done
		say @B"VNC password successfully configured." green
		echo "Please note that VNC password is NOT needed for browser access."
		sleep 1
	fi
	echo 
	say @B"Would you like to set up Nginx Reverse Proxy?" yellow
	say @B"Please note that if you want to copy or paste text between the server and your computer, you MUST set up an Nginx Reverse Proxy AND an SSL certificate.  You can set it up later manually though." yellow
	echo "Please type [Y/n]:"
	read install_nginx
	if [ "x$install_nginx" != "xn" ] && [ "x$install_nginx" != "xN" ] ; then
		echo 
		say @B"Please tell me your domain name (e.g., desktop.qing.su):" yellow
		read guacamole_hostname
		echo 
		echo 
		echo "Would you like to install a free Let's Encrypt certificate for domain name ${guacamole_hostname}? [Y/N]"
		say @B"Please point your domain name to this server IP BEFORE continuing!" yellow
		echo "Type Y if you are sure that your domain is now pointing to this server IP."
		read confirm_letsencrypt
		echo 
		if [ "x$confirm_letsencrypt" = "xY" ] || [ "x$confirm_letsencrypt" = "xy" ] ; then
			echo "Please input an e-mail address:"
			read le_email
		fi
	else
		say @B"OK, Nginx will NOT be installed on this server." yellow
	fi
	echo 
	say @B"Desktop environment installation will start now.  Please wait." green
	sleep 3
}	

function install_guacamole_ubuntu_debian
{
	echo 
	say @B"Setting up dependencies..." yellow
	echo 
	apt-get update && apt-get upgrade -y
	apt-get install wget curl sudo zip unzip tar perl expect build-essential libcairo2-dev libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev tomcat9 tomcat9-admin tomcat9-common tomcat9-user japan* chinese* korean* fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core -y
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install libjpeg62-turbo-dev -y
	else
		apt-get install libjpeg-turbo8-dev language-pack-ja language-pack-zh* language-pack-ko -y
	fi
	wget $GUACAMOLE_DOWNLOAD_LINK
	tar zxf guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	rm -f guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	cd $CurrentDir/guacamole-server-$GUACAMOLE_VERSION
	echo "Start building Guacamole Server from source..."
	./configure --with-init-dir=/etc/init.d
	if [ -f $CurrentDir/guacamole-server-$GUACAMOLE_VERSION/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	sleep 2
	make
	make install
	ldconfig
	echo "Trying to start Guacamole Server for the first time..."
	echo "This can take a while..."
	echo 
	systemctl daemon-reload
	systemctl start guacd
	systemctl enable guacd
	ss -lnpt | grep guacd >/dev/null
	if [ $? = 0 ] ; then
		say @B"Guacamole Server successfully installed!" green
		echo 
	else 
		say "Guacamole Server installation failed." red
		say @B"Please check the above log for reasons." yellow
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		exit 1
	fi
}

function install_guacamole_centos
{
	echo 
	say @B"Setting up dependencies..." yellow
	echo 
	if [ "$OS" = "CENTOS8" ] ; then
		dnf -y update
		dnf -y group install "Development Tools"
		dnf -y install --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
		dnf -y install http://rpmfind.net/linux/epel/7/x86_64/Packages/s/SDL2-2.0.10-1.el7.x86_64.rpm
		dnf -y install http://mirror.centos.org/centos/8/Devel/x86_64/os/Packages/libuv-devel-1.23.1-1.el8.x86_64.rpm
		dnf -y --enablerepo=PowerTools install perl expect cairo cairo-devel libpng-devel libtool uuid libjpeg-devel libjpeg-turbo-devel freerdp freerdp-devel pango-devel libssh2-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libwebp-devel libwebsockets-devel libvorbis-devel ffmpeg-devel uuid-devel ffmpeg ffmpeg-devel mingw64-filesystem
		yum -y groupinstall Fonts
		dnf -y install java-11-openjdk-devel
	else
		yum update -y
		yum -y install epel-release
		yum -y install wget curl vim tar sudo zip unzip perl git cairo-devel freerdp-devel freerdp-plugins gcc gnu-free-mono-fonts libjpeg-turbo-devel libjpeg-turbo-official libpng-devel libssh2-devel libtelnet-devel libvncserver-devel libvorbis-devel libwebp-devel libwebsockets-devel openssl-devel pango-devel policycoreutils-python pulseaudio-libs-devel setroubleshoot uuid-devel
		yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
		yum -y install ffmpeg ffmpeg-devel
		yum -y groupinstall Fonts
		yum -y install java-11-openjdk-devel
	fi
	install_tomcat9_centos
	wget $GUACAMOLE_DOWNLOAD_LINK
	tar zxf guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	rm -f guacamole-server-${GUACAMOLE_VERSION}.tar.gz
	cd $CurrentDir/guacamole-server-$GUACAMOLE_VERSION
	echo "Start building Guacamole Server from source..."
	./configure --with-init-dir=/etc/init.d
	if [ -f $CurrentDir/guacamole-server-$GUACAMOLE_VERSION/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	sleep 2
	make
	make install
	ldconfig
	echo "Trying to start Guacamole Server for the first time..."
	echo "This can take a while..."
	echo 
	service guacd start
	chkconfig guacd on
	ss -lnpt | grep guacd >/dev/null
	if [ $? = 0 ] ; then
		say @B"Guacamole Server successfully installed!" green
		echo 
	else 
		say "Guacamole Server installation failed." red
		say @B"Please check the above log for reasons." yellow
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		exit 1
	fi
}

function install_tomcat9_centos
{
	curl -s https://mirrors.ocf.berkeley.edu/apache/tomcat/tomcat-9/v9.0.38/bin/apache-tomcat-9.0.38.tar.gz | tar -xz
	mv apache-tomcat-9.0.38 /etc/tomcat9
	echo "export CATALINA_HOME="/etc/tomcat9"" >> ~/.bashrc
	source ~/.bashrc
	useradd -r tomcat
	chown -R tomcat:tomcat /etc/tomcat9
	cat > /etc/systemd/system/tomcat9.service <<END
[Unit]
Description=Apache Tomcat Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=CATALINA_PID=/etc/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/etc/tomcat9
Environment=CATALINA_BASE=/etc/tomcat9

ExecStart=/etc/tomcat9/bin/catalina.sh start
ExecStop=/etc/tomcat9/bin/catalina.sh stop

RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
END
	systemctl daemon-reload
	systemctl start tomcat9
	systemctl enable tomcat9
}
	
function install_guacamole_web
{
	echo 
	echo "Start installaing Guacamole Web Application..."
	cd $CurrentDir
	wget https://downloads.apache.org/guacamole/$GUACAMOLE_VERSION/binary/guacamole-$GUACAMOLE_VERSION.war
	if [ "$OS" = "CENTOS7" ] || [ "$OS" = "CENTOS8" ] ; then
		mv guacamole-$GUACAMOLE_VERSION.war /etc/tomcat9/webapps/guacamole.war
	else
		mv guacamole-$GUACAMOLE_VERSION.war /var/lib/tomcat9/webapps/guacamole.war
	fi
	systemctl restart tomcat9 guacd
	echo 
	say @B"Guacamole Web Application successfully installed!" green
	echo 
}

function configure_guacamole_ubuntu_debian
{
	echo 
	mkdir /etc/guacamole/
	cat > /etc/guacamole/guacamole.properties <<END
guacd-hostname: localhost
guacd-port: 4822
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
END
	if [ $choice_rdpvnc = 1 ] ; then
		if [ $set_rdp_resolution = 0 ] ; then
			cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
       </connection>
    </authorize>
</user-mapping>
END
		else
			cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
		 <param name="width">$rdp_screen_width</param>
		 <param name="height">$rdp_screen_height</param>
       </connection>
    </authorize>
</user-mapping>
END
		fi
	else
		cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>vnc</protocol>
         <param name="hostname">localhost</param>
         <param name="port">5901</param>
         <param name="password">$vnc_password</param>
       </connection>
    </authorize>
</user-mapping>
END
	fi
	systemctl restart tomcat9 guacd
	say @B"Guacamole successfully configured!" green
	echo 
}

function configure_guacamole_centos
{
	echo 
	mkdir /etc/guacamole/
	cat > /etc/guacamole/guacamole.properties <<END
guacd-hostname: localhost
guacd-port: 4822
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
END
	if [ $set_rdp_resolution = 0 ] ; then
		cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
		 <param name="security">rdp</param>
       </connection>
    </authorize>
</user-mapping>
END
	else
		cat > /etc/guacamole/user-mapping.xml <<END
<user-mapping>
    <authorize
         username="$guacamole_username"
         password="$guacamole_password_md5"
         encoding="md5">      
       <connection name="default">
         <protocol>rdp</protocol>
         <param name="hostname">localhost</param>
         <param name="port">3389</param>
		 <param name="width">$rdp_screen_width</param>
		 <param name="height">$rdp_screen_height</param>
		 <param name="security">rdp</param>
       </connection>
    </authorize>
</user-mapping>
END
	fi
	systemctl restart tomcat9 guacd
	say @B"Guacamole successfully configured!" green
	echo 
}

function install_vnc
{
	echo 
	echo "Starting to install desktop, browser, and VNC server..."
	say @B"Please note that if you are asked to configure LightDM during this step, simply press Enter." yellow
	echo 
	echo "Press Enter to continue."
	read catch_all
	echo 
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install xfce4 xfce4-goodies firefox-esr tigervnc-standalone-server tigervnc-common -y
	else 
		apt-get install xfce4 xfce4-goodies firefox tigervnc-standalone-server tigervnc-common -y
	fi
	say @B"Desktop, browser, and VNC server successfully installed." green
	echo "Starting to configure VNC server..."
	sleep 2
	echo 
	mkdir $HomeDir/.vnc
	cat > $HomeDir/.vnc/xstartup <<END
#!/bin/bash

xrdb $HomeDir/.Xresources
startxfce4 &
END
	cat > /etc/systemd/system/vncserver@.service <<END
[Unit]
Description=a wrapper to launch an X server for VNC
After=syslog.target network.target

[Service]
Type=forking
User=$CurrentUser
Group=$CurrentUser
WorkingDirectory=$HomeDir

ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 -localhost :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
END
	vncpassbinpath=/usr/bin/vncpasswd
	/usr/bin/expect <<END
spawn "$vncpassbinpath"
expect "Password:"
send "$vnc_password\r"
expect "Verify:"
send "$vnc_password\r"
expect "Would you like to enter a view-only password (y/n)?"
send "n\r"
expect eof
exit
END
	vncserver
	sleep 2
	vncserver -kill :1
	systemctl start vncserver@1.service
	systemctl enable vncserver@1.service
	/usr/bin/vncconfig -display :1 &
	cat > $HomeDir/Desktop/EnableCopyPaste.sh <<END
#!/bin/bash
/usr/bin/vncconfig -display :1 &
END
	chmod +x $HomeDir/Desktop/EnableCopyPaste.sh
	echo 
	ss -lnpt | grep vnc > /dev/null
	if [ $? = 0 ] ; then
		say @B"VNC and desktop successfully configured!" green
		echo 
	else
		say "VNC installation failed!" red
		say @B"Please check the above log for reasons." yellow
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		exit 1
	fi
}

function install_rdp
{
	echo 
	echo "Starting to install desktop, browser, and XRDP server..."
	if [ "$OS" = "UBUNTU18" ] || [ "$OS" = "UBUNTU20" ] ; then
		say @B"Please note that if you are asked to configure LightDM during this step, simply press Enter." yellow
		echo 
		echo "Press Enter to continue."
		read catch_all
		echo
	fi
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install xfce4 xfce4-goodies firefox-esr xrdp -y
	elif [ "$OS" = "CENTOS8" ] || [ "$OS" = "CENTOS7" ] ; then
		yum -y groupinstall "Server with GUI"
		yum -y install firefox
		compile_xrdp_centos
		yum -y install xorgxrdp
		echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
	else
		apt-get install xfce4 xfce4-goodies firefox xrdp -y
	fi
	say @B"Desktop, browser, and XRDP server successfully installed." green
	echo "Starting to configure XRDP server..."
	sleep 2
	echo 
	if [ "$OS" != "CENTOS7" ] && [ "$OS" != "CENTOS8" ] ; then
		mv /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.backup
		cat > /etc/xrdp/startwm.sh <<END
#!/bin/sh
# xrdp X session start script (c) 2015, 2017 mirabilos
# published under The MirOS Licence

if test -r /etc/profile; then
        . /etc/profile
fi

if test -r /etc/default/locale; then
        . /etc/default/locale
        test -z "${LANG+x}" || export LANG
        test -z "${LANGUAGE+x}" || export LANGUAGE
        test -z "${LC_ADDRESS+x}" || export LC_ADDRESS
        test -z "${LC_ALL+x}" || export LC_ALL
        test -z "${LC_COLLATE+x}" || export LC_COLLATE
        test -z "${LC_CTYPE+x}" || export LC_CTYPE
        test -z "${LC_IDENTIFICATION+x}" || export LC_IDENTIFICATION
        test -z "${LC_MEASUREMENT+x}" || export LC_MEASUREMENT
        test -z "${LC_MESSAGES+x}" || export LC_MESSAGES
        test -z "${LC_MONETARY+x}" || export LC_MONETARY
        test -z "${LC_NAME+x}" || export LC_NAME
        test -z "${LC_NUMERIC+x}" || export LC_NUMERIC
        test -z "${LC_PAPER+x}" || export LC_PAPER
        test -z "${LC_TELEPHONE+x}" || export LC_TELEPHONE
        test -z "${LC_TIME+x}" || export LC_TIME
        test -z "${LOCPATH+x}" || export LOCPATH
fi

if test -r /etc/profile; then
        . /etc/profile
fi

 xfce4-session

test -x /etc/X11/Xsession && exec /etc/X11/Xsession
exec /bin/sh /etc/X11/Xsession

END
		chmod +x /etc/xrdp/startwm.sh
	fi
	systemctl enable xrdp
	systemctl restart xrdp
	sleep 5
	echo "Waiting to start XRDP server..."
	systemctl restart guacd
	cat > /etc/systemd/system/restartguacd.service <<END
[Unit]
Descript=Restart GUACD

[Service]
ExecStart=/etc/init.d/guacd start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

END
	systemctl daemon-reload
	systemctl enable restartguacd
	ss -lnpt | grep xrdp > /dev/null
	if [ $? = 0 ] ; then
		ss -lnpt | grep guacd > /dev/null
		if [ $? = 0 ] ; then
			say @B"XRDP and desktop successfully configured!" green
		else 
			say @B"XRDP and desktop successfully configured!" green
			sleep 3
			systemctl start guacd
		fi
		echo 
	else
		say "XRDP installation failed!" red
		say @B"Please check the above log for reasons." yellow
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		exit 1
	fi
}

function compile_xrdp_centos
{
	if [ "$OS" = "CENTOS7" ] ; then
		yum -y install firefox finger cmake patch gcc make autoconf libtool automake pkgconfig openssl-devel gettext file pam-devel libX11-devel libXfixes-devel libjpeg-devel libXrandr-devel nasm flex bison gcc-c++ libxslt perl-libxml-perl xorg-x11-font-utils xmlto-tex
	else
		dnf -y --enablerepo=PowerTools install firefox cmake patch gcc make autoconf libtool automake pkgconfig openssl-devel gettext file pam-devel libX11-devel libXfixes-devel libjpeg-devel libXrandr-devel nasm flex bison gcc-c++ libxslt perl-libxml-perl xorg-x11-font-utils
	fi
	echo 
	say @B"Starting to build xrdp from source..." yellow
	sleep 2
	cd $CurrentDir
	git clone --recursive https://github.com/neutrinolabs/xrdp.git
	cd xrdp
	./bootstrap
	./configure
	if [ -f $CurrentDir/xrdp/config.status ] ; then
		say @B"Dependencies met!" green
		say @B"Compiling now..." green
		echo
	else
		echo 
		say "Missing dependencies." red
		echo "Please check log, install required dependencies, and run this script again."
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		echo 
		exit 1
	fi
	sleep 2
	make
	make install
	systemctl start xrdp
	echo 
	ss -lnpt | grep xrdp >/dev/null
	if [ $? = 0 ] ; then
		say @B"Xrdp successfully installed!" green
		echo 
	else 
		say "XRDP installation failed!" red
		say @B"Please check the above log for reasons." yellow
		echo "Please also consider to report your log here https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix this issue."
		echo "Thank you!"
		exit 1
	fi
}

function display_license
{
	echo 
	echo '*******************************************************************'
	echo '*       One-click Desktop & Browser Access Setup Script           *'
	echo '*       Version 0.2.0                                             *'
	echo '*       Author: shc (Har-Kuun) https://qing.su                    *'
	echo '*       https://github.com/Har-Kuun/OneClickDesktop               *'
	echo '*       Thank you for using this script.  E-mail: hi@qing.su      *'
	echo '*******************************************************************'
	echo 
}

function install_reverse_proxy
{
	echo 
	say @B"Setting up Nginx reverse proxy..." yellow
	sleep 2
	if [ "$OS" = "CENTOS8" ] ; then
		dnf -y install nginx certbot python3-certbot-nginx
		systemctl enable nginx
		systemctl start nginx
	elif [ "$OS" = "CENTOS7" ] ; then
		yum -y install nginx certbot python-certbot-nginx
		systemctl enable nginx
		systemctl start nginx
	else
		apt-get install nginx certbot python3-certbot-nginx -y
	fi
		say @B"Nginx successfully installed!" green
	cat > /etc/nginx/conf.d/guacamole.conf <<END
server {
        listen 80;
        listen [::]:80;
        server_name $guacamole_hostname;

        access_log  /var/log/nginx/guac_access.log;
        error_log  /var/log/nginx/guac_error.log;

        location / {
                    proxy_pass http://127.0.0.1:8080/guacamole/;
                    proxy_buffering off;
                    proxy_http_version 1.1;
                    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                    proxy_set_header Upgrade \$http_upgrade;
                    proxy_set_header Connection \$http_connection;
                    proxy_cookie_path /guacamole/ /;
        }

}
END
	systemctl reload nginx
	if [ "x$confirm_letsencrypt" = "xY" ] || [ "x$confirm_letsencrypt" = "xy" ] ; then
		certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email $le_email -d $guacamole_hostname
		echo 
		if [ -f /etc/letsencrypt/live/$guacamole_hostname/fullchain.pem ] ; then
			say @B"Congratulations! Let's Encrypt SSL certificate installed successfully!" green
			say @B"You can now access your desktop at https://${guacamole_hostname}!" green
		else
			say "Oops! Let's Encrypt SSL certificate installation failed." red
			say @B"Please manually try \"certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email $le_email -d $guacamole_hostname\"." yellow
			say @B"You can now access your desktop at http://${guacamole_hostname}!" green
		fi
	else
		say @B"Let's Encrypt certificate not installed! If you would like to install a Let's Encrypt certificate later, please manually run \"certbot --nginx --agree-tos --redirect --hsts --staple-ocsp -d $guacamole_hostname\"." yellow
		say @B"You can now access your desktop at http://${guacamole_hostname}!" green
	fi
	say @B"Your Guacamole username is $guacamole_username and your Guacamole password is $guacamole_password_prehash." green
}

function main
{
	display_license
	if [ "x$OS_CHECK_ENABLED" != "xOFF" ] ; then
		check_OS
	fi
	echo "This script is going to install a desktop environment with browser access."
	echo 
	if [ "$OS" = "CENTOS7" ] || [ "$OS" = "CENTOS8" ] ; then
		say @B"This environment requires at least 1.5 GB of RAM." yellow
	else
		say @B"This environment requires at least 1 GB of RAM." yellow
	fi
	echo 
	echo "Would you like to proceed? [Y/N]"
	read confirm_installation
	if [ "x$confirm_installation" = "xY" ] || [ "x$confirm_installation" = "xy" ] ; then
		determine_system_variables
		get_user_options
		if [ "$OS" = "CENTOS7" ] || [ "$OS" = "CENTOS8" ] ; then
			install_guacamole_centos
		else
			install_guacamole_ubuntu_debian
		fi
		install_guacamole_web
		if [ "$OS" = "CENTOS7" ] || [ "$OS" = "CENTOS8" ] ; then
			configure_guacamole_centos
		else
			configure_guacamole_ubuntu_debian
		fi
		if [ $choice_rdpvnc = 1 ] ; then
			install_rdp
		else
			install_vnc
		fi
		if [ "x$install_nginx" != "xn" ] && [ "x$install_nginx" != "xN" ] ; then
			install_reverse_proxy
		else
			say @B"You can now access your desktop at http://$(curl -s icanhazip.com):8080/guacamole!" green
			say @B"Your Guacamole username is $guacamole_username and your password is $guacamole_password_prehash." green
		fi
		if [ $choice_rdpvnc = 1 ] ; then
			echo 
			say @B"Note that after entering Guacamole using the above Guacamole credentials, you will be asked to input your Linux server username and password in the XRDP login panel, which is NOT the guacamole username and password above.  Please use the default Xorg as session type." yellow
		fi
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
