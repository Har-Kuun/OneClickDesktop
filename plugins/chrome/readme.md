This is a simple guide to install Chrome browser on the Guacamole-XRDP-Xfce4 based Linux desktop.

Please note that, this guide is written for the RDP version of OneClickDesktop.  If you are using the VNC version, this guide will NOT work for you.  Please use the [chrome script](https://github.com/Har-Kuun/OneClickDesktop/blob/master/plugins/chrome/ChromeBrowser.sh) to install instead.

## Chrome Installation Guide for Debian/Ubuntu Users

### 1. Install GDebi

Log in to the SSH, or open the Terminal Emulator on your Linux desktop.  Run the following command:

```
sudo apt-get install gdebi -y
```

### 2. Install Chrome

(1) Use your web browser, enter your Linux desktop, with `root` account.  This step is very important; using any other account, even with sudo privilege, will NOT work.  Please rest assured that only the installation step requires root privilege; using Chrome does NOT need root privilege.

(2) Open your default web browser (Firefox), navigate to https://www.google.com/chrome/, and click `Download Chrome` in the center of the page.

(3) A Download Chrome for Linux message box will pop up.  Please choose the `64bit .deb` version, click `Accept and Install`, and save the .deb package to your disk.

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/download_chrome.png)

(4) Navigate to the Downloads folder `/root/Downloads/` using the File Manager.  Right click on the .deb file, then left click the first option `Open with "GDebi Package Installer"`.

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/install_with_gdebi.png)

(5) Click `Install Package`.

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/installing_chrome.png)

(6) After a few seconds, the `Installation Finished` message will show up.  You can then close all windows, then __LOG OUT__ of the desktop.

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/installation_finished.png)

### 3. Use Chrome

In order to use Chrome, you have to log in to your Linux desktop with a `non-root` account.

After logging in, click the `Application` in the upper-left corner of your desktop screen, scroll down to `Internet`, and you will see `Chrome` right below `Firefox`.

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/use_chrome.png)

You can now start to use the Chrome browser.  If you wish, you can set it as your default browser.

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/chrome_installation_completed.png)


## Chrome Installation Guide for CentOS Users

### 1. Install Chrome

Chrome installation in CentOS is easy.  Simply SSH into your server or use its desktop terminal, and run the following command.

```
sudo yum -y localinstall https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
```

### 2. Use Chrome

In order to use Chrome, you have to log in to your Linux desktop with a `non-root` account.

After logging in, click the `Application` in the upper-left corner of your desktop screen, scroll down to `Internet`, and you will see `Chrome` right below `Firefox`.

CentOS 7:

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/use_chrome_centos7.png)

---

CentOS 8:

![](https://github.com/Har-Kuun/OneClickDesktop/raw/master/plugins/chrome/use_chrome_centos8.png)

You can now start to use the Chrome browser.  If you wish, you can set it as your default browser.
