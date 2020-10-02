# OneClickDesktop
A one-click script that installs a remote desktop environment on a Linux server with browser/VNC/RDP access.

## Features of this script
* Build Guacamole Server from source.
* Set up Guacamole Web APP.
* Install Tomcat 9, XRDP (or TigerVNC), XFCE4 Desktop, Firefox.
* One-click free SSL certificates from Let's Encrypt
* You can access your remote desktop from browsers, no need for RDP or VNC software.

## System requirement
* A __freshly installed__ server, with Ubuntu 18.04/20.04 LTS 64 bit, Debian 10 64 bit, or CentOS 7/8 64 bit system
* __Do NOT install any web server programs (e.g., Apache, Nginx, LiteSpeed, Caddy).  Do NOT install LAMP or LEMP stack.  Do NOT install any admin panels (e.g., cPanel, DirectAdmin, BTcn, VestaCP).  They are NOT compatible with this script.__
* 1 IPv4
* For Debian/Ubuntu users, at least 1.0 GB RAM is required; 1.5+ GB is recommended.
* For CentOS users, at least 1.5 GB RAM is required; 2.0+ GB is recommended.
* Root access, or sudo user

## How to use
* Firstly, you need to find a spare VPS with at least 1 IPv4, and install Ubuntu 18.04/20.04 LTS 64 bit (recommended), Debian 10 64 bit, or CentOS 7/8 64 bit OS.
* You need a domain name (can be a subdomain) which points to the IP address of your server.
* Then, please run the following command as a sudo user in SSH.
```
wget https://raw.githubusercontent.com/Har-Kuun/OneClickDesktop/master/OneClickDesktop.sh && sudo bash OneClickDesktop.sh
```
* The script will guide you through the installation process.
* If you encounter any errors, please check the `OneClickDesktop.log` file that's located within the same directory where you download this script.
* Please consider reporting the error log at https://github.com/Har-Kuun/OneClickDesktop/issues so that I can fix any underlying issues.
* Copy/paste between client and server should have been enabled by default.  If you have any problems with copy/paste when using VNC method, please try to run the EnableCopyPaste.sh file on your Desktop.

## Plugins
There is a few plugin scripts/addons available.
* A very simple guide to install Chrome browser.  Check out https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/chrome/readme.md
* One-click change Guacamole login password.  Check out https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/change-Guacamole-password.sh
* Tutorial to install Baiduyun Net Disk client.  Check out https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/baiduyun.md

Please submit an issue if you want more plugins to be written.

## Contact me
You can open an issue here if there is any problem/bug when you use it, or would like a new feature to be implemented.
For faster response, you can leave a message on this project webpage https://qing.su/article/oneclick-desktop.html

中文支持请访问 https://qing.su/article/oneclick-desktop.html

Thank you!

## Frequently Asked Questions (FAQ)

### General

1. Q: Should I choose RDP or VNC?
* A: I'd always choose RDP.  It performs better than VNC by all means.

2. Q: Which OS should I use?
* A: This script supports Ubuntu 18/20, Debian 10, and CentOS 7/8.  OS choice mainly comes down to personal preferences.  There are a couple points that I'd love to note here.  If you choose Debian 10, LibreOffice will be installed out-of-the-box after running this script.  If you choose CentOS 7/8, the script will install GNOME instead of XFCE4 desktop environment (hence the extra 0.5 GB RAM consumption); GNOME is fancier than XFCE4, but renders a bit slower.  Also note that for CentOS 7/8, a lot of packages will be downloaded from third-party repositories (rpmfusion, rpmfind, etc.), or cloned from Github; if that is an issue to you, please use Debian or Ubuntu instead.

3. Q: Should I use my root user or a non-root user to use my desktop?
* A: For RDP, you should always use a non-root user, unless you wish to install some certain software on your desktop.  To create a non-root user, simply run `adduser USERNAME` in your terminal or SSH.  For VNC, there is no option to select an user unless you modify the script itself, so you don't have to worry about this.

4. Q: Should I choose to set up Nginx reverse proxy and Let's Encrypt SSL?
* A: Unless you are installing your desktop environment alongside a production environment (which is highly discouraged), you should always choose to set up Nginx reverse proxy and Let's Encrypt SSL.  Please note that unless you enable SSL for your desktop access, your browser probably won't let you copy-paste between the remote desktop and your local computer.  If you are installing this desktop environment alongside a production environment, you should set up your current webserver software (Apache, Nginx, Litespeed, Caddy, etc.) as a reverse proxy of http://127.0.0.1:8080/guacamole and set up SSL for it.

5. Q: Are there any security measures that can be taken to make this desktop environment safer?
* A: Yes.  First of all, RDP is safer than VNC in this special case, so I would always choose RDP if possible.  Secondly, I will set up firewall rules to only allow traffic through port 80 and 443, unless you need to connect to your desktop using other VNC/RDP client software other than your browser, and if that's the case, please change the default port (3389 for RDP and 5901 for VNC) to something else.

### Installation

6. Q: My installation failed; why?
* A: I am not able to anwser this question unless you provide more details.  Please check the `OneClickDesktop.log` file which is located in the same folder where you run this script, and check for any errors.  Please then check the following questions for an anwser or report these errors/logs by opening an Iuuse in this repository, and I can then respond accordingly.

7. Q: My Nginx installation failed, why?
* A: This is most likely due to you have another webserver installed and running (for example, Apache2).  You need to uninstall all other webserver programs before running this script, or skip the Nginx reverse proxy part of the installation and set up reverse proxy manually after the installation.

8. Q: My Let's Encrypt SSL installation failed, why?
* A: One possibility is that you did not enter a valid e-mail address when you asked you to; but most likely, this problem is because __the domain name you are using is not (yet) pointing to the IP address of your server__.  Note that it may take up to 48 hours for DNS changes to propagate throughout the world.  If you are using Cloudflare DNS, you will need to use the "DNS Only" mode in order to provision a Let's Encrypt SSL; you can otherwise use the free SSL from Cloudflare, and skip the SSL step here instead.  A very rare case is that if you have provisioned too many Let's Encrypt SSL certificates recently for this domain name, the Let's Encrypt SSL installation may also fail; in this case, please use another domain instead, or wait a couple of days.

9. Q: My Tomcat server fails to start, why?
* A: This usually happens on CentOS when Selinux is enabled.  Selinux might prohibit Tomcat from running.  If this happens, you should consider disabling Selinux or changing its rules, then start Tomcat9 server manually by running `service tomcat9 start`.

10. Q: The script tells me that I am missing dependencies.  Shouldn't dependencies be handled already in the script?
* A: This happens frequently to Chinese users who use Aliyun mirrors.  Aliyun mirrors have some sort of disgusting rate limitations, which might leads to incomplete installation of dependencies through apt/yum/dnf.  Please change your mirror source to another source, then run this script again.  If you are not using Aliyun mirror and still saw the missing dependencies notice, please report it by rasing an issue here so that I can fix it.

11. Q: The script got killed during compilation; what happened?
* A: This is very unusual, but may happen if your server does not have enough RAM; please add some SWAP and run the script again.

### Post-Installation

12. Q: Can I change my Guacamole username and password?
* A: Yes, please check out the password-update script here. https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/change-Guacamole-password.sh

13. Q: My desktop is laggy; can I improve the user experience?
* A: Yes, to some extent.  Firstly, if you are still using VNC, I'd recommend you reinstall your server and run the script again using the RDP mode; it makes your life easier.  Secondly, if you are using CentOS, switching to Ubuntu or Debian might help, because the desktop of CentOS is fancier and renders slower.  Thirdly, you can decrease the screen resolution by editting `/etc/guacamole/user-mapping.xml` file.  Of course, if you are able to use a server that's nearer to you physically, that will help a lot.

14. Q: I cannot copy-paste between my server's desktop and my own computer, why?
* A: As mentioned before, you have to set up SSL for your Guacamole; otherwise your browser will not allow you to copy-paste between the two servers.

15. Q: I cannot hear anything when I use my server desktop to watch videos, why?
* A: If you are using a VPS, you are not supposed to hear anything because it does not have a sound card.

16. Q: Can I install Software XXX/YYY/ZZZ on this desktop?
* A: Most likely, yes.  If you are using CentOS, there is an APP store on your desktop, and you can search for the software you want; if you are using Debian/Ubuntu, you can simply google "How to install XXX on ubuntu 20" and you can usually find a dozen tutorials.

17. Q: Is there a clean way to uninstall everything installed by this script?
* A: Not at this moment.  I'd recommend a reinstallation of your server.  I might write an uninstallation script in the future though.

## References
* Guacamole documentation: https://guacamole.apache.org/doc/gug/installing-guacamole.html
* The author thanks LinuxBabe for providing a [detailed Guacamole/VNC setup tutorial for Debian/Ubuntu](https://www.linuxbabe.com/debian/apache-guacamole-remote-desktop-debian-10-buster).

## Update log
 __Current version: v0.1.0__

|Date|Version|Changes|
|---|---|---|
|08/02/2020|v0.0.1|Script created|
|08/03/2020|v0.0.2|Enable copy/paste; add Asian characters support.|
|09/25/2020|v0.1.0|Add RDP feature; improve installation experience.|
|09/29/2020|v0.2.0|Add CentOS 7/8 support.|
