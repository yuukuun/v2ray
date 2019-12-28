#!/bin/bash

###添加证书
read -p "请输入你的域名：" domain
read -p "请输入SSL证书的CERTIFICATE：" cer
read -p "请输入SSL证书的KEY：" key
echo "$cer" >> /usr/local/nginx/ssl/"$domain".pem
echo "$key" >> /usr/local/nginx/ssl/"$domain".key


###启动nginx
if [[ /usr/local/nginx/sbin/nginx -t ]];then
	sudo systemctl enable nginx.service
	sudo systemctl start nginx.service
else
	echo "Nginx 启动失败，请检查SSL证书或其他问题！"
if