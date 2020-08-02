#!/bin/bash
###########################################################################################
#    One-click Desktop & Browser Access Setup Script v0.0.1                               #
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

#By default, this script only works on Ubuntu 18/20 and Debian 10.
#You can disable the OS check switch below and tweak the code yourself to try to install it in other OS versions.
#Please do note that if you choose to use this script on OS other than Ubuntu 18/20 or Debian 10, you might mess up your OS.  Please keep a backup of your server before installation.

OS_CHECK_ENABLED=ON




#########################################################################
#    Functions start here.                                              #
#    Do not change anything below unless you know what you are doing.   #
#########################################################################

exec > >(tee -i OneClickDesktop.log)
exec 2>&1

function check_OS
{
	if [ -f /etc/lsb-release ]
	then
		cat /etc/lsb-release | grep "DISTRIB_RELEASE=18." >/dev/null
		if [ $? = 0 ]
		then
			OS=UBUNTU18
		else
			cat /etc/lsb-release | grep "DISTRIB_RELEASE=20." >/dev/null
			if [ $? = 0 ]
			then
				OS=UBUNTU20
			else
				say "Sorry, this script only supports Ubuntu 18, 20 and Debian 10." red
				echo 
				exit 1
			fi
		fi
	elif [ -f /etc/debian_version ] ; then
		cat /etc/debian_version | grep "^10." >/dev/null
		if [ $? = 0 ] ; then
			OS=DEBIAN10
		else
			say "Sorry, this script only supports Ubuntu 18, 20 and Debian 10." red
			echo 
			exit 1
		fi
	else
		say "Sorry, this script only supports Ubuntu 18, 20 and Debian 10." red
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

function install_guacamole
{
	echo 
	say @B"Setting up dependencies..." yellow
	echo 
	apt-get update && apt-get upgrade -y
	apt-get install wget curl sudo zip unzip tar perl expect build-essential libcairo2-dev libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev libavformat-dev tomcat9 tomcat9-admin tomcat9-common tomcat9-user -y
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install libjpeg62-turbo-dev -y
	else
		apt-get install libjpeg-turbo8-dev -y
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

function install_guacamole_web
{
	echo 
	echo "Start installaing Guacamole Web Application..."
	cd $CurrentDir
	wget https://downloads.apache.org/guacamole/$GUACAMOLE_VERSION/binary/guacamole-$GUACAMOLE_VERSION.war
	mv guacamole-$GUACAMOLE_VERSION.war /var/lib/tomcat9/webapps/guacamole.war
	systemctl restart tomcat9 guacd
	echo 
	say @B"Guacamole Web Application successfully installed!" green
	echo 
}

function configure_guacamole
{
	echo 
	say @B"Please input your username:" yellow
	read guacamole_username
	echo 
	say @B"Please input your password:" yellow
	read guacamole_password_prehash
	echo 
	read guacamole_password_md5 <<< $(echo -n $guacamole_password_prehash | md5sum | awk '{print $1}')
	while [ ${#vnc_password} != 8 ] ; do
		say @B"Please input your 8-character VNC password:" yellow
		read vnc_password
	done
	echo "Please note that VNC password is NOT needed for browser access."
	sleep 1
	echo 
	mkdir /etc/guacamole/
	cat > /etc/guacamole/guacamole.properties <<END
guacd-hostname: localhost
guacd-port: 4822
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
basic-user-mapping: /etc/guacamole/user-mapping.xml
END
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
	systemctl restart tomcat9 guacd
	say @B"Guacamole successfully configured!" green
	echo 
}

function install_desktop
{
	echo 
	echo "Starting to install desktop, browser, and VNC server..."
	say @B"Please note that if you are asked to configure LightDM during this step, simply press Enter." yellow
	echo 
	echo "Press Enter to continue."
	read catch_all
	echo 
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install xfce4 xfce4-goodies firefox-esr tigervnc-standalone-server -y
	else 
		apt-get install xfce4 xfce4-goodies firefox tigervnc-standalone-server -y
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

function display_license
{
	echo 
	echo '*******************************************************************'
	echo '*       One-click Desktop & Browser Access Setup Script           *'
	echo '*       Version 0.0.1                                             *'
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
	apt-get install nginx certbot python3-certbot-nginx -y
	say @B"Nginx successfully installed!" green
	echo 
	echo "Please tell me your domain name (e.g., desktop.qing.su):"
	read guacamole_hostname
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
	echo 
	echo "Would you like to install a free Let's Encrypt certificate for domain name ${guacamole_hostname}? [Y/N]"
	say @B"Please point your domain name to this server IP BEFORE continuing!" yellow
	echo "Type Y if you are sure that your domain is now pointing to this server IP."
	read confirm_letsencrypt
	echo 
	if [ "x$confirm_letsencrypt" = "xY" ] || [ "x$confirm_letsencrypt" = "xy" ] ; then
		echo "Please input an e-mail address:"
		read le_email
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
		say @B"No problem! If you would like to install a Let's Encrypt certificate later, please manually run \"certbot --nginx --agree-tos --redirect --hsts --staple-ocsp -d $guacamole_hostname\"." yellow
		say @B"You can now access your desktop at http://${guacamole_hostname}!" green
	fi
	say @B"Your username is $guacamole_username and your password is $guacamole_password_prehash." green
}

function main
{
	display_license
	if [ "x$OS_CHECK_ENABLED" != "xOFF" ] ; then
		check_OS
	fi
	echo "This script is going to install a desktop environment with browser access."
	echo 
	say @B"This environment requires at least 1 GB of RAM." yellow
	echo 
	echo "Would you like to proceed? [Y/N]"
	read confirm_installation
	if [ "x$confirm_installation" = "xY" ] || [ "x$confirm_installation" = "xy" ] ; then
		determine_system_variables
		install_guacamole
		install_guacamole_web
		configure_guacamole
		install_desktop
		install_reverse_proxy
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
