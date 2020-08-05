# OneClickDesktop
A one-click script that installs a remote desktop environment on a Linux server with browser/VNC access.

## Features of this script
* Build Guacamole Server from source.
* Set up Guacamole Web APP.
* Install Tomcat 9, TigerVNC, XFCE4 Desktop, Firefox.
* One-click free SSL certificates from Let's Encrypt
* You can access your remote desktop from browsers, no need for VNC software.

## System requirement
* A __freshly installed__ server, with Ubuntu 18.04/20.04 LTS 64 bit or Debian 10 64 bit system
* __Do NOT install any web server programs (e.g., Apache, Nginx, LiteSpeed, Caddy).  Do NOT install LAMP or LEMP stack.  Do NOT install any admin panels (e.g., cPanel, DirectAdmin, BTcn, VestaCP).  They are NOT compatible with this script.__
* 1 IPv4
* At least 1024 MB RAM; 1.5+ GB is recommended.
* Root access, or sudo user

## How to use
* Firstly, you need to find a spare VPS with at least 1 IPv4, and install Ubuntu 18.04/20.04 LTS 64 bit (recommended) or Debian 10 64 bit OS.
* You need a domain name (can be a subdomain) which points to the IP address of your server.
* Then, please run the following command as a sudo user in SSH.
```
wget https://raw.githubusercontent.com/Har-Kuun/OneClickDesktop/master/OneClickDesktop.sh && sudo bash OneClickDesktop.sh
```
* The script will guide you through the installation process.
* If you encounter any errors, please check the `OneClickDesktop.log` file that's located within the same directory where you download this script.
* Please consider reporting the error log at https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix any underlying issues.
* Copy/paste between client and server should be enabled.  If you have any problems with copy/paste, please try to run the EnableCopyPaste.sh file on your Desktop.

## Plugins
There is a few plugin scripts/addons available.
* One-click install Chrome browser.  Check out https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/ChromeBrowser.sh
* One-click change web-login password.  Check out https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/change-Guacamole-password.sh
* Tutorial to install Baiduyun Net Disk client.  Check out https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/baiduyun.md
Please submit an issue if you want more plugins to be written.

## Contact me
You can open an issue here if there is any problem/bug when you use it, or would like a new feature to be implemented.
For faster response, you can leave a message on this project webpage https://qing.su/article/oneclick-desktop.html

中文支持请访问 https://qing.su/article/oneclick-desktop.html

Thank you!

## References
* Guacamole documentation: https://guacamole.apache.org/doc/gug/installing-guacamole.html
* The author thanks LinuxBabe for providing a [detailed Guacamole setup tutorial](https://www.linuxbabe.com/debian/apache-guacamole-remote-desktop-debian-10-buster).

## Update log
 __Current version: v0.0.1__

|Date|Version|Changes|
|---|---|---|
|08/02/2020|v0.0.1|Script created|
|08/03/2020|v0.0.2|Enable copy/paste; add Asian characters support.|
