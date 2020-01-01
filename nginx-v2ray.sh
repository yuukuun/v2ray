#!/bin/bash
###支持 CentOS 7/8 系列，Ubuntu 19/18/16 系列
### wget https://yuukuun.github.io/v2ray/installall.sh && chmod +x installall.sh && ./installall.sh

################################### Install Nginx ... ################################### 
read -p "请输入域名：" url
num=$(cat /etc/redhat-release | cut -d " " -f4 | cut -d "." -f1)
sudo sed -i 's/=enforcing/=disabled/g' /etc/selinux/config
sudo mkdir -p /usr/local/nginx/ssl /usr/local/nginx/conf.d
#判断是否redhat系列
if [[ -f /etc/redhat-release ]];then
	sudo systemctl start firewalld
    sudo firewall-cmd --add-service=http
    sudo firewall-cmd --add-service=https
    sudo firewall-cmd --runtime-to-permanent
    sudo firewall-cmd --reload
    sudo systemctl enable firewalld 
    sudo systemctl stop firewalld
sudo yum install -y vim libtool zip perl-core zlib-devel gcc wget pcre* unzip automake autoconf make curl 
      if [[ $num == "7" ]]; then
          sudo yum remove -y epel-release
          sudo yum install -y epel-release
          sudo yum install -y certbot python2-certbot-nginx
      elif [[ $num == "8" ]]; then
          wget https://dl.eff.org/certbot-auto
          sudo mv certbot-auto /usr/local/bin/certbot-auto
          sudo chown root /usr/local/bin/certbot-auto
          sudo chmod 0755 /usr/local/bin/certbot-auto
      fi

#判断是否ubuntu系列
elif [[ -f /etc/lsb-release ]];then 
    cd /tmp
    sudo apt-get update
    ##证书用的
    sudo apt-get install software-properties-common -y
	sudo add-apt-repository universe -y
	sudo add-apt-repository ppa:certbot/certbot -y
	sudo apt-get update
	## 证书用的certbot python-certbot-nginx
    sudo apt-get install certbot python-certbot-nginx gcc zip vim wget curl unzip build-essential libtool zlib1g-dev libpcre3 \
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

#开始安装nginx
cd /tmp
wget https://www.openssl.org/source/openssl-1.1.1a.tar.gz
tar xzvf openssl-1.1.1a.tar.gz 
wget https://nginx.org/download/nginx-1.15.8.tar.gz
tar xf nginx-1.15.8.tar.gz && rm nginx-1.15.8.tar.gz
cd nginx-1.15.8
./configure --prefix=/usr/local/nginx --with-openssl=../openssl-1.1.1a --with-openssl-opt='enable-tls1_3' \
--with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module \
--with-http_sub_module --with-stream --with-stream_ssl_module
sudo make && sudo make install

#nginx配置1
sudo cat > /usr/local/nginx/conf/nginx.conf <<-EOF
user  root;
worker_processes  1;
error_log  /usr/local/nginx/logs/error.log warn;
pid        /usr/local/nginx/logs/nginx.pid;
events {
    worker_connections  1024;
}
http {
    include       /usr/local/nginx/conf/mime.types;
    default_type  application/octet-stream;
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /usr/local/nginx/logs/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    keepalive_timeout  120;
    client_max_body_size 20m;
    #gzip  on;
    include /usr/local/nginx/conf.d/*.conf;  
    server { 
	    listen       80;
	    server_name  $url;
	    root /usr/local/nginx/html/;
	    index index.php index.html;
	    #rewrite ^(.*)$  https://\$host\$1 permanent; 
    } 
}
EOF

#nginx启动
sudo cat >/etc/systemd/system/nginx.service<<-EOF
[Unit]
Description=nginx
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl start nginx.service


################################### Install v2ray ... ################################### 
bash <(curl -L -s https://install.direct/go.sh)
uuid=$(/usr/bin/uuidgen)

sudo rm -rf /etc/v2ray/config.json
sudo cat >/etc/v2ray/config.json<<-EOF
{
  "log" : {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": 11234,
    "listen":"127.0.0.1",
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$uuid",
          "level": 1,
          "alterId": 64,
          "email": "10000@qq.com"
        }
      ]
    },
     "streamSettings": {
      "network": "ws",
      "wsSettings": {
         "path": "/7ba7"
        }
     }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  }
}
EOF
sudo systemctl enable v2ray
sudo systemctl start v2ray

################################### Get v2ray ... ################################### 
dir="/usr/local/nginx/html/v2ray/"
sudo mkdir -p "$dir" && cd "$dir" 
wget https://github.com/2dust/v2rayN/releases/download/3.3/v2rayN-Core.zip && unzip v2rayN-Core.zip && rm -rf "$dir"*.zip

cat >"$dir"v2rayN-Core/guiNConfig.json<<-EOP
{
  "inbound": [
    {
      "localPort": 10808,
      "protocol": "socks",
      "udpEnabled": true,
      "sniffingEnabled": true
    }
  ],
  "logEnabled": false,
  "loglevel": "warning",
  "index": 0,
  "vmess": [
    {
      "configVersion": 2,
      "address": "$url",
      "port": 443,
      "id": "$uuid",
      "alterId": 64,
      "security": "auto",
      "network": "ws",
      "remarks": "",
      "headerType": "none",
      "requestHost": "",
      "path": "/7ba7",
      "streamSecurity": "tls",
      "allowInsecure": "",
      "configType": 1,
      "testResult": "",
      "subid": ""
    }
  ],
  "muxEnabled": true,
  "domainStrategy": "IPIfNonMatch",
  "routingMode": "0",
  "useragent": [],
  "userdirect": [],
  "userblock": [],
  "kcpItem": {
    "mtu": 1350,
    "tti": 50,
    "uplinkCapacity": 12,
    "downlinkCapacity": 100,
    "congestion": false,
    "readBufferSize": 2,
    "writeBufferSize": 2
  },
  "listenerType": 2,
  "urlGFWList": "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt",
  "allowLANConn": false,
  "enableStatistics": false,
  "statisticsFreshRate": 2000,
  "remoteDNS": null,
  "subItem": [],
  "uiItem": {
    "mainQRCodeWidth": 600
  },
  "userPacRule": []
}
EOP
zip -r "$dir"v2rayN-Core.zip v2rayN-Core/ && rm -rf v2rayN-Core/

###主页创建###
cd "$dir"
wget https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/css/bootstrap.min.css
wget https://github.com/2dust/v2rayNG/releases/download/1.1.14/v2rayNG_1.1.14.apk
wget https://yuukuun.github.io/v2ray/android_1.jpg
wget https://yuukuun.github.io/v2ray/android_2.jpg

cat >"$dir"index.html<<-EOP
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>v2ray 客户端</title>
    <!-- Bootstrap -->
    <link href="bootstrap.min.css" rel="stylesheet">
  </head>
  <body>
<div class="container"><div class="row">
<!-- 下载客户端 -->
<h4><div class="alert alert-success" align="center">下载</div></h4>
<a type="button" class="btn btn-primary btn-lg" href="v2rayN-Core.zip" target="_blank">Windows客户端</a>
<a type="button" class="btn btn-primary btn-lg" href="v2rayNG_1.1.14.apk" target="_blank">安卓客户端</a>
<!--<a type="button" class="btn btn-primary btn-lg" href="v2rayNG_1.1.14.apk" target="_blank">IOS客户端</a>-->
<!-- 参数设置 -->
<h4><div class="alert alert-success" align="center">客户端参数</div></h4>
  <div class="table-responsive">
    <table class="table table-striped table-bordered table-hover">
      <tr><th>属性</tH><th>参数</th></tr>
      <tr><td>协议：</td><td>vmess</td></tr>
      <tr><td>域名地址：</td><td>$url</td></tr>
      <tr><td>UUID：</td><td>$uuid</td></tr>
      <tr><td>端口：</td><td>443</td></tr>
      <tr><td>额外ID：</td><td>64</td></tr>
      <tr><td>传输协议：</td><td>ws</td></tr>
      <tr><td>PATH：</td><td>/7ba7</td></tr>
      <tr><td>传输安全：</td><td>TLS</td></tr>
    </table>
  </div>  
<!-- 安卓客户端参数 -->
<h4><div class="alert alert-success " align="center">安卓客户端：域名和UUID修改成自己的</div>
<img class="img-responsive col-sm-12 col-md-6" src="android_1.jpg"/>
<img class="img-responsive col-sm-12 col-md-6" src="android_2.jpg"/>
</h4>

</div></div>
<!-- 这里写script -->
  </body>
</html>

EOP
sudo chmod 755 -R "$dir"
cp -r "$dir" ~/
/usr/local/nginx/sbin/nginx -s reload
sudo systemctl restart nginx
sleep 5

################################### Add SSL ... ################################### 
###证书获取###


if [[ $num == "8" ]]; then
  sudo /usr/local/bin/certbot-auto certonly --webroot -w /usr/local/nginx/html/ -d "$url" -m qwe@yahoo.com --agree-tos
  echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew" | \
  sudo tee -a /etc/crontab > /dev/null
else
  sudo certbot certonly --webroot -w /usr/local/nginx/html/ -d "$url" -m qwe@yahoo.com --agree-tos
  echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew" | \
  sudo tee -a /etc/crontab > /dev/null  
fi


sleep 10
###写入配置
sudo cat > /usr/local/nginx/conf.d/$url.conf<<-EOF
server {
    listen 443 ssl http2;
    server_name $url;
    root /usr/local/nginx/html/;
    index index.php index.html;
    ssl_certificate  /etc/letsencrypt/live/$url/fullchain.pem; 
    ssl_certificate_key /etc/letsencrypt/live/$url/privkey.pem;
    #TLS 版本控制
    ssl_protocols   TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers     'TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5';
    ssl_prefer_server_ciphers   on;
    # 开启 1.3 0-RTT
    ssl_early_data  on;
    ssl_stapling on;
    ssl_stapling_verify on;
    #add_header Strict-Transport-Security "max-age=31536000";
    #access_log /var/log/nginx/access.log combined;
    location /7ba7 {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:11234; 
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
    location / {
       try_files \$uri \$uri/ /index.php?\$args;
    }
}
EOF

/usr/local/nginx/sbin/nginx -t
/usr/local/nginx/sbin/nginx -s reload
sudo systemctl restart nginx
sudo systemctl enable nginx
