#安装v2ray的服务端

if [[ $url == "" ]];then
    read -p "请输入您的二级域名 : " url
fi

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

sudo systemctl enable v2ray.service
sudo systemctl start v2ray.service	

###输出信息###
echo "#################################################"
echo "域名地址： $url"
echo "协议：   vmess"
echo "端口：   443"
echo "UUID：   $uuid"
echo "额外ID： 64"
echo "传输协议： ws"
echo "PATH：   /7ba7"
echo "传输安全： TLS"
echo "#################################################"
