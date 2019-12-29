###v2ray客户端安装###

if [[ $url == "" ]];then
    read -p "请输入您的二级域名 : " url
fi
if [[ $uuid == "" ]];then
    uuid=$(cat /etc/v2ray/config.json | grep '"id"' | cut -d '"' -f4)
fi



dir="/usr/local/nginx/html/down/"
sudo mkdir "$dir" && cd "$dir"
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

cp -r "$dir" ~/