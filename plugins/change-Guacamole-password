#!/bin/bash

#This script will change your Guacamole Web Application login credentials (username and password).
#Please run this script as a sudo user or root user.
#Note that this script will NOT change your VNC password.
#If Guacamole fails to connect after changing the password, please reboot your server.

function change_passwd
{
	echo 
	echo "You are about to change your Guacamole login credentials."
	sleep 2
	echo "Please input your new username (alphanumeric only):" 
	read guacamole_username
	echo 
	echo "Please input your new password (alphanumeric only):"
	read guacamole_password_prehash
	echo 
	read guacamole_password_md5 <<< $(echo -n $guacamole_password_prehash | md5sum | awk '{print $1}')
	new_username_line="         username=\"$guacamole_username\""
	new_password_line="         password=\"$guacamole_password_md5\""
	old_username_line="$(grep username= /etc/guacamole/user-mapping.xml)"
	old_password_line="$(grep password= /etc/guacamole/user-mapping.xml)"
	echo 
	sed -i "s#$old_username_line#$new_username_line#g" /etc/guacamole/user-mapping.xml
	sed -i "s#$old_password_line#$new_password_line#g" /etc/guacamole/user-mapping.xml
	systemctl restart tomcat9 guacd
	echo "Guacamole login credentials successfully changed!"
	echo 
}

change_passwd
