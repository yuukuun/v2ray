#!/bin/bash
### Nginx + V2ray + TLS + Websocks 模式 ， 支持系统  CentOS 7/8系列 , ubuntu 16/18

### 安装步骤 ### 
### wget https://yuukuun.github.io/v2ray/install.sh && chmod +x install.sh && ./install.sh
### 输入域名


read -p "PLEASE INTER DOMAIN : " url
###判断是否redhat系列###
if [[ -f /etc/redhat-release ]];then
	sudo systemctl start firewalld
	sudo firewall-cmd --add-service=http
	sudo firewall-cmd --add-service=https
	sudo firewall-cmd --runtime-to-permanent
	sudo firewall-cmd --reload
	sudo systemctl enable firewalld 
	sudo systemctl stop firewalld
	sudo yum install -y libtool zip perl-core zlib-devel gcc wget pcre* unzip automake autoconf make curl vim
#判断是否ubunturedhat系列
elif [[ -f /etc/lsb-release ]];then 
	cd /tmp
	sudo apt-get update
	sudo apt-get install gcc zip vim wget curl unzip build-essential libtool zlib1g-dev libpcre3 \
	libpcre3-dev libssl-dev automake autoconf make -y
	wget http://www.cpan.org/src/5.0/perl-5.26.1.tar.gz
	tar -xzf perl-5.26.1.tar.gz
	cd perl-5.26.1
	sudo mkdir /usr/local/perl
	./Configure -des -Dprefix=/usr/local/perl
	make && make install
else
	echo "###################### Install error ... ######################"
fi

### 本地创建目录
sudo mkdir ~/v2rays && cd ~/v2rays 
wget https://yuukuun.github.io/v2ray/nginx.sh
wget https://yuukuun.github.io/v2ray/v2rayserver.sh
wget https://yuukuun.github.io/v2ray/v2rayclient.sh
wget https://yuukuun.github.io/v2ray/addssl.sh

###入入库###

. ~/v2rays/nginx.sh
. ~/v2rays/v2rayserver.sh
. ~/v2rays/v2rayclient.sh
#. ~/v2rays/addssl.sh	#最后运行这个脚本
chmod +x ~/v2rays/*.sh

###输出信息###
echo "#################################################"
echo "域名地址：	$url"
echo "协议：		vmess"
echo "端口：		443"
echo "UUID：		$uuid"
echo "额外ID：	64"
echo "传输协议：	ws"
echo "PATH：		/7ba7"
echo "传输安全：	TLS"
echo "#################################################"

