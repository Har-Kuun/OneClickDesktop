#!/bin/bash
###########################################################################################
#    One-click Desktop & Browser Access Setup Script v0.0.2                               #
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


#您可以在这里修改Guacamole源码下载链接。
#访问https://guacamole.apache.org/releases/获取最新源码。

GUACAMOLE_DOWNLOAD_LINK="https://mirrors.ocf.berkeley.edu/apache/guacamole/1.2.0/source/guacamole-server-1.2.0.tar.gz"
GUACAMOLE_VERSION="1.2.0"

#此脚本仅支持Ubuntu 18/20或Debian 10.
#如果您试图再其他版本的操作系统中安装，可以在下面禁用OS检查开关。
#请注意，在其他操作系统上安装此脚本可能会导致不可预料的错误。请在安装前做好备份。

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
				say "很抱歉，此脚本仅支持Ubuntu 18/20与Debian 10操作系统。" red
				echo 
				exit 1
			fi
		fi
	elif [ -f /etc/debian_version ] ; then
		cat /etc/debian_version | grep "^10." >/dev/null
		if [ $? = 0 ] ; then
			OS=DEBIAN10
		else
			say "很抱歉，此脚本仅支持Ubuntu 18/20与Debian 10操作系统。" red
			echo 
			exit 1
		fi
	else
		say "很抱歉，此脚本仅支持Ubuntu 18/20与Debian 10操作系统。" red
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
	say @B"安装依赖环境..." yellow
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
	echo "开始安装Guacamole服务器..."
	./configure --with-init-dir=/etc/init.d
	if [ -f $CurrentDir/guacamole-server-$GUACAMOLE_VERSION/config.status ] ; then
		say @B"编译条件已满足！" green
		say @B"开始编译源码..." green
		echo
	else
		echo 
		say "依赖环境缺失。" red
		echo "请核查日志，安装必要的依赖环境，并再次运行此脚本。"
		echo "欢迎您在https://github.com/Har-Kuun/OneClickDesktop/issues这里提交错误报告，以便我修复脚本。"
		echo "谢谢！"
		echo 
		exit 1
	fi
	sleep 2
	make
	make install
	ldconfig
	echo "第一次启动Guacamole服务器可能需要较长时间..."
	echo "请耐心等待..."
	echo 
	systemctl daemon-reload
	systemctl start guacd
	systemctl enable guacd
	ss -lnpt | grep guacd >/dev/null
	if [ $? = 0 ] ; then
		say @B"Guacamole服务器安装成功！" green
		echo 
	else 
		say "Guacamole服务器安装失败。" red
		say @B"请检查上面的日志。" yellow
		echo "欢迎您在https://github.com/Har-Kuun/OneClickDesktop/issues这里提交错误报告，以便我修复脚本。"
		echo "谢谢！"
		exit 1
	fi
}

function install_guacamole_web
{
	echo 
	echo "开始安装Guacamole Web应用..."
	cd $CurrentDir
	wget https://downloads.apache.org/guacamole/$GUACAMOLE_VERSION/binary/guacamole-$GUACAMOLE_VERSION.war
	mv guacamole-$GUACAMOLE_VERSION.war /var/lib/tomcat9/webapps/guacamole.war
	systemctl restart tomcat9 guacd
	echo 
	say @B"Guacamole Web应用成功安装！" green
	echo 
}

function configure_guacamole
{
	echo 
	say @B"请输入您的用户名:" yellow
	read guacamole_username
	echo 
	say @B"请输入您的密码:" yellow
	read guacamole_password_prehash
	echo 
	read guacamole_password_md5 <<< $(echo -n $guacamole_password_prehash | md5sum | awk '{print $1}')
	while [ ${#vnc_password} != 8 ] ; do
		say @B"请输入一个长度为8位的VNC密码:" yellow
		read vnc_password
	done
	echo "通过浏览器方式访问远程桌面时，您将无需使用此VNC密码。"
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
	say @B"Guacamole配置成功！" green
	echo 
}

function install_desktop
{
	echo 
	echo "开始安装桌面环境，Firefox浏览器，以及VNC服务器..."
	say @B"如果系统提示您配置LightDM，您可以直接按回车键。" yellow
	echo 
	echo "请按回车键继续。"
	read catch_all
	echo 
	if [ "$OS" = "DEBIAN10" ] ; then
		apt-get install xfce4 xfce4-goodies firefox-esr tigervnc-standalone-server -y
	else 
		apt-get install xfce4 xfce4-goodies firefox tigervnc-standalone-server -y
	fi
	say @B"桌面环境，浏览器，以及VNC服务器安装成功。" green
	echo "开始配置VNC服务器..."
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
	cat > $HomeDir/Desktop/EnableCopyPaste.sh <<END
#!/bin/bash
/usr/bin/vncconfig -display :1 &
END
	chmod +x $HomeDir/Desktop/EnableCopyPaste.sh
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
	echo 
	ss -lnpt | grep vnc > /dev/null
	if [ $? = 0 ] ; then
		say @B"VNC与远程桌面配置成功！" green
		echo 
	else
		say "VNC安装失败！" red
		say @B"请检查上面的日志。" yellow
		echo "欢迎您在https://github.com/Har-Kuun/OneClickDesktop/issues这里提交错误报告，以便我修复脚本。"
		echo "谢谢！"
		exit 1
	fi
}

function display_license
{
	echo 
	echo '*******************************************************************'
	echo '*       One-click Desktop & Browser Access Setup Script           *'
	echo '*       Version 0.0.2                                             *'
	echo '*       Author: shc (Har-Kuun) https://qing.su                    *'
	echo '*       https://github.com/Har-Kuun/OneClickDesktop               *'
	echo '*       Thank you for using this script.  E-mail: hi@qing.su      *'
	echo '*******************************************************************'
	echo 
}

function install_reverse_proxy
{
	echo 
	say @B"安装Nginx反代..." yellow
	sleep 2
	apt-get install nginx certbot python3-certbot-nginx -y
	say @B"Nginx安装成功！" green
	echo 
	echo "请输入您的域名（比如desktop.qing.su）:"
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
	echo "是否为域名${guacamole_hostname}申请免费的Let's Encrypt SSL证书？ [Y/N]"
	say @B"设置证书之前，您必须将您的域名指向本服务器的IP地址！" yellow
	echo "如果您确认了您的域名已经指向了本服务器的IP地址，请输入Y开始证书申请。"
	read confirm_letsencrypt
	echo 
	if [ "x$confirm_letsencrypt" = "xY" ] || [ "x$confirm_letsencrypt" = "xy" ] ; then
		echo "请输入一个邮箱地址:"
		read le_email
		certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email $le_email -d $guacamole_hostname
		echo 
		if [ -f /etc/letsencrypt/live/$guacamole_hostname/fullchain.pem ] ; then
			say @B"恭喜！Let's Encrypt SSL证书安装成功！" green
			say @B"开始使用您的远程桌面，请在浏览器中访问 https://${guacamole_hostname}!" green
		else
			say "Let's Encrypt SSL证书安装失败。" red
			say @B"您可以请手动执行 \"certbot --nginx --agree-tos --redirect --hsts --staple-ocsp --email $le_email -d $guacamole_hostname\"." yellow
			say @B"开始使用您的远程桌面，请在浏览器中访问 http://${guacamole_hostname}!" green
		fi
	else
		say @B"好的，如果您之后需要安装Let's Encrypt证书，请手动执行 \"certbot --nginx --agree-tos --redirect --hsts --staple-ocsp -d $guacamole_hostname\"." yellow
		say @B"开始使用您的远程桌面，请在浏览器中访问 http://${guacamole_hostname}!" green
	fi
	say @B"您的用户名是$guacamole_username，密码是 $guacamole_password_prehash。" green
}

function main
{
	display_license
	if [ "x$OS_CHECK_ENABLED" != "xOFF" ] ; then
		check_OS
	fi
	echo "此脚本将在本服务器上安装一个桌面环境。您可以随时随地在浏览器上使用这个桌面环境。"
	echo 
	say @B"此桌面环境需要至少1 GB内存。" yellow
	echo 
	echo "请问是否继续？ [Y/N]"
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
	echo "感谢您的使用！此脚本作者为https://qing.su"
	echo "祝您生活愉快！"
}

###############################################################
#                                                             #
#               The main function starts here.                #
#                                                             #
###############################################################

main
exit 0
