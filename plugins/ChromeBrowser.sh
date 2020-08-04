#!/bin/bash

#This script installs Chrome browser on your desktop.
#Simply run "wget https://raw.githubusercontent.com/Har-Kuun/OneClickDesktop/master/plugins/ChromeBrowser.sh && sudo bash ChromeBrowser.sh"
#After installation, Chrome browser can be launched by double-clicking the "StartChrome.sh" file on your Desktop.

echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
wget https://dl.google.com/linux/linux_signing_key.pub
apt-key add linux_signing_key.pub
apt-get update -y
apt-get install google-chrome-stable -y
rm -f linux_signing_key.pub

cat > $HOME/Desktop/StartChrome.sh <<END
#!/bin/bash
google-chrome-stable --no-sandbox
END
chmod +x $HOME/Desktop/StartChrome.sh

echo "Google Chrome installed successfully!"
echo "Please double-click \"StartChrome.sh\" on your Desktop to run Chrome."
echo "Thank you! -- https://qing.su"
