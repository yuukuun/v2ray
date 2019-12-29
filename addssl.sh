###安装~/.acme.sh/acme.sh
# read -p "请输入您的二级域名 : " url

if [[ $url == "" ]];then
    read -p "请输入您的二级域名 : " url
fi
if [[ ! -d /usr/local/nginx ]];then
    sudo mkdir -p /usr/local/nginx/ssl /usr/local/nginx/conf.d
fi

###DNS选择###
echo "1.阿里云 DNS"
echo "2.CloudFlare DNS"
read -p "请选择1-2：" num
case $num in
1) 
	dns="dns_ali"
	echo "阿里云获取KEY：https://ak-console.aliyun.com/#/accesskey"
	read -p "请输入阿里云Ali_Key：" Ali_Key
	read -p "请输入阿里云Ali_Secret：" Ali_Secret
	export Ali_Key && echo 'export Ali_Key="$Ali_Key"' >> ~/.bashrc
	export Ali_Secret && echo 'export Ali_Secret="$Ali_Secret"' >> ~/.bashrc
;;
2)
	dns="dns_cf"
	echo "CloudFlare获取KEY：https://dash.cloudflare.com/profile/api-tokens"
	read -p "请输入CloudFlare CF_Key：" CF_Key
	read -p "请输入CloudFlare CF_Email：" CF_Email
	export CF_Key && echo 'export CF_Key="$CF_Key"' >> ~/.bashrc
	export CF_Email && echo 'export CF_Email="$CF_Email"' >> ~/.bashrc
;; 
*) echo "输入错误！" ;;	
esac

###安装证书###
wget -O -  https://get.acme.sh | sh
~/.acme.sh/acme.sh --issue --dns $dns -d $url -d  "*.$url"

#nginx配置
sudo cat > /usr/local/nginx/conf.d/$url.conf<<-EOF
server { 
    listen       80;
    server_name  $url;
    rewrite ^(.*)$  https://\$host\$1 permanent; 
}
server {
    listen 443 ssl http2;
    server_name $url;
    root /usr/local/nginx/html;
    index index.php index.html;
    ssl_certificate  $HOME/.acme.sh/$url/fullchain.cer; 
    ssl_certificate_key $HOME/.acme.sh/$url/$url.key;
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

/usr/local/nginx/sbin/nginx -s reload

