#!/bin/bash

##获
wget -O -  https://get.acme.sh | sh

/root/.acme.sh/acme.sh --issue -d  mgleek.mn -w /usr/local/nginx/html/
#acme.sh --issue -d $url -w /usr/local/nginx/html/


##nginx启动
#sudo systemctl enable nginx.service
#sudo systemctl start nginx.service

yum -y install yum-utils
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
sudo yum install certbot python2-certbot-nginx

sudo certbot --nginx
certbot certonly --webroot -w /usr/local/nginx/html/ -d mgleek.mn
echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | sudo tee -a /etc/crontab > /dev/null


#!/bin/bash
#install certbot
#如果安装出错，删除epel-release  重新安装epel-release
#sudo yum remove epel-release
#sudo yum install -y epel-release
 
yum install -y certbot python2-certbot-nginx
 
certbot --nginx certonly
 
certbot certonly --webroot -w /usr/local/nginx/html/ -d mgleek.mn    #这里写自己域名
certbot renew --dry-run