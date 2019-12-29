###nginx的安装

#初始化
	echo "I######################  Install Nginx ... ######################"

if [[ ! -d /usr/local/nginx ]];then
    sudo mkdir -p /usr/local/nginx/ssl /usr/local/nginx/conf.d
fi



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
#判断是否ubuntu系列
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
sudo systemctl enable nginx.service


