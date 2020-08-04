### 您可以按照下面的步骤安装百度云网盘客户端。

__请注意，百度云网盘仅能在Ubuntu 18.04与Ubuntu 20.04 64位系统上安装。Debian系统中无法安装百度云。__

1. 访问https://pan.baidu.com/download, 获取最新版本的Linux deb安装包下载链接。

2. 下载该安装包，比如：
```
wget http://wppkg.baidupcs.com/issue/netdisk/Linuxguanjia/3.3.2/baidunetdisk_3.3.2_amd64.deb
```

3. 安装该deb包：
```
sudo dpkg -i baidunetdisk_3.3.2_amd64.deb
```

4. 如果安装过程中依赖缺失，可以执行下面的命令安装依赖环境：
```
sudo apt install -f
```

安装完毕后，回到桌面环境，依次点击左上角`Applications -- Internet -- baidunetdisk`即可运行百度云客户端。
