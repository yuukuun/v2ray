#!/bin/bash
### Nginx + V2ray + TLS + Websocks 模式 ， 支持系统  CentOS 7/8系列 , ubuntu 16/18

### 安装步骤 ### 
### wget https://yuukuun.github.io/v2ray/install.sh && chmod +x install.sh && ./install.sh
### 输入域名

read -p "请输入您的二级域名 : " url

### 本地创建目录
# sudo mkdir ~/v2rays && cd ~/v2rays 
# wget https://yuukuun.github.io/v2ray/nginx.sh
# wget https://yuukuun.github.io/v2ray/v2rayserver.sh
# wget https://yuukuun.github.io/v2ray/v2rayclient.sh
# wget https://yuukuun.github.io/v2ray/addssl.sh
# chmod +x *.sh

###入入库###
. ~/v2rays/addssl.sh
. ~/v2rays/nginx.sh

. ~/v2rays/v2rayserver.sh
. ~/v2rays/v2rayclient.sh

chmod +x ~/v2rays/*.sh


