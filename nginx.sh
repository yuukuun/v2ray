###nginx的安装

#初始化
	echo "I###################### Nginx Install ... ######################"
	sudo mkdir /usr/local/nginx
	sudo mkdir /usr/local/nginx/ssl
	sudo mkdir /usr/local/nginx/conf.d

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
#nginx配置2
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
    ssl_certificate /usr/local/nginx/ssl/$url.pem; 
    ssl_certificate_key /usr/local/nginx/ssl/$url.key;
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
#nginx ssl密钥是
sudo cat >/usr/local/nginx/ssl/$url.pem<<-EOP
-----BEGIN CERTIFICATE-----
MIIFsTCCBJmgAwIBAgIQA2D3FCcnJC78+h7U2w7emjANBgkqhkiG9w0BAQsFADBy
MQswCQYDVQQGEwJDTjElMCMGA1UEChMcVHJ1c3RBc2lhIFRlY2hub2xvZ2llcywg
SW5jLjEdMBsGA1UECxMURG9tYWluIFZhbGlkYXRlZCBTU0wxHTAbBgNVBAMTFFRy
dXN0QXNpYSBUTFMgUlNBIENBMB4XDTE5MTIyNTAwMDAwMFoXDTIwMTIyNDEyMDAw
MFowGTEXMBUGA1UEAxMObGFpeXVlcWlhbi5jb20wggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQDWTd6YcRpeAq5e+ySzZmYLT0F6A5fhd5QU5rI+QKU4PVsT
vJ8hy/5WyrKvg7yw7d+kdr6Km+Ckwx7LGvVsd24PPkPi2Wr6VS2ZYaV3Xh4XHIRT
FrWO5yCoYz9wzB7HFRDCr34j9O1Q4J6nTMHYTChlafsr1d+kBTf9cMilg6FnW7s0
/+sMdoP+hZYmN30g+VnCCLGdlSoxYmyykZbMLq25xDyFuVbVcREanB5ebKt8YODW
QLwZEuq/mffO6uxlf8wjcW2UZikmBiuZq7MT3TFC7fUUAWlOCDzGV/4NW5AU4I9I
ysHuc8FWzFbxcslK6gqSQlhzgiUZiOkEEm4hlZztAgMBAAGjggKaMIICljAfBgNV
HSMEGDAWgBR/05nzoEcOMQBWViKOt8ye3coBijAdBgNVHQ4EFgQUtYWEjU5FurP+
ffMFnWo0b7H0qrcwLQYDVR0RBCYwJIIObGFpeXVlcWlhbi5jb22CEnd3dy5sYWl5
dWVxaWFuLmNvbTAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEG
CCsGAQUFBwMCMEwGA1UdIARFMEMwNwYJYIZIAYb9bAECMCowKAYIKwYBBQUHAgEW
HGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCAYGZ4EMAQIBMIGSBggrBgEF
BQcBAQSBhTCBgjA0BggrBgEFBQcwAYYoaHR0cDovL3N0YXR1c2UuZGlnaXRhbGNl
cnR2YWxpZGF0aW9uLmNvbTBKBggrBgEFBQcwAoY+aHR0cDovL2NhY2VydHMuZGln
aXRhbGNlcnR2YWxpZGF0aW9uLmNvbS9UcnVzdEFzaWFUTFNSU0FDQS5jcnQwCQYD
VR0TBAIwADCCAQYGCisGAQQB1nkCBAIEgfcEgfQA8gB3AKS5CZC0GFgUh7sTosxn
cAo8NZgE+RvfuON3zQ7IDdwQAAABbzvWbDQAAAQDAEgwRgIhANRiieBE/qFSwSxb
nhWyS7+6FUkOcwqcZlDVQCiA5JgmAiEA+a3t+cQSZ17DGFkvhwl/Pqe9jSvYiChD
9WONBDqBus0AdwBep3P531bA57U2SH3QSeAyepGaDIShEhKEGHWWgXFFWAAAAW87
1mviAAAEAwBIMEYCIQC4ro7a6a3jutnw6e2cpnYzj774nvumcyt0gsLeTkFM+QIh
AJQxrYn1NsVv9dUqbyfjXZrJYC2tK6yHpA0TrpeIZEfEMA0GCSqGSIb3DQEBCwUA
A4IBAQCMi8hYp45apH7pwlpZJRxrhtRPr3xUQHcBKoCqIIZyOFaw8h7vNbRW6rOD
PtQJDjNlFSTOBAYBYLG4W7+G285aBz/BG8acouCHkq9s01TIc1sBA2c/ugLDKNHg
R0i3DG2hTbRdnAvvkxdoEWwH9suKuQ6nAdKK3j0x12zknWxntMJdboQ9omgv2/XU
AEj0yhT9GdidsN9Xv0APwwIumEUl6EK5AjSS8B9sR23m6sGIziIjfphN5CfMENEc
HubxX2PvvD1KGlnVJJTVjCmaMjAg0IXLpnhNpbFw0epC793/KHridAkOTryTB1HL
Icbk+Hhg0iq4GxZ/SXao11gm8Fzl
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIErjCCA5agAwIBAgIQBYAmfwbylVM0jhwYWl7uLjANBgkqhkiG9w0BAQsFADBh
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSAwHgYDVQQDExdEaWdpQ2VydCBHbG9iYWwgUm9vdCBD
QTAeFw0xNzEyMDgxMjI4MjZaFw0yNzEyMDgxMjI4MjZaMHIxCzAJBgNVBAYTAkNO
MSUwIwYDVQQKExxUcnVzdEFzaWEgVGVjaG5vbG9naWVzLCBJbmMuMR0wGwYDVQQL
ExREb21haW4gVmFsaWRhdGVkIFNTTDEdMBsGA1UEAxMUVHJ1c3RBc2lhIFRMUyBS
U0EgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCgWa9X+ph+wAm8
Yh1Fk1MjKbQ5QwBOOKVaZR/OfCh+F6f93u7vZHGcUU/lvVGgUQnbzJhR1UV2epJa
e+m7cxnXIKdD0/VS9btAgwJszGFvwoqXeaCqFoP71wPmXjjUwLT70+qvX4hdyYfO
JcjeTz5QKtg8zQwxaK9x4JT9CoOmoVdVhEBAiD3DwR5fFgOHDwwGxdJWVBvktnoA
zjdTLXDdbSVC5jZ0u8oq9BiTDv7jAlsB5F8aZgvSZDOQeFrwaOTbKWSEInEhnchK
ZTD1dz6aBlk1xGEI5PZWAnVAba/ofH33ktymaTDsE6xRDnW97pDkimCRak6CEbfe
3dXw6OV5AgMBAAGjggFPMIIBSzAdBgNVHQ4EFgQUf9OZ86BHDjEAVlYijrfMnt3K
AYowHwYDVR0jBBgwFoAUA95QNVbRTLtm8KPiGxvDl7I90VUwDgYDVR0PAQH/BAQD
AgGGMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjASBgNVHRMBAf8ECDAG
AQH/AgEAMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
ZGlnaWNlcnQuY29tMEIGA1UdHwQ7MDkwN6A1oDOGMWh0dHA6Ly9jcmwzLmRpZ2lj
ZXJ0LmNvbS9EaWdpQ2VydEdsb2JhbFJvb3RDQS5jcmwwTAYDVR0gBEUwQzA3Bglg
hkgBhv1sAQIwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29t
L0NQUzAIBgZngQwBAgEwDQYJKoZIhvcNAQELBQADggEBAK3dVOj5dlv4MzK2i233
lDYvyJ3slFY2X2HKTYGte8nbK6i5/fsDImMYihAkp6VaNY/en8WZ5qcrQPVLuJrJ
DSXT04NnMeZOQDUoj/NHAmdfCBB/h1bZ5OGK6Sf1h5Yx/5wR4f3TUoPgGlnU7EuP
ISLNdMRiDrXntcImDAiRvkh5GJuH4YCVE6XEntqaNIgGkRwxKSgnU3Id3iuFbW9F
UQ9Qqtb1GX91AJ7i4153TikGgYCdwYkBURD8gSVe8OAco6IfZOYt/TEwii1Ivi1C
qnuUlWpsF1LdQNIdfbW3TSe0BhQa7ifbVIfvPWHYOu3rkg1ZeMo6XRU9B4n5VyJY
RmE=
-----END CERTIFICATE-----
EOP
sudo cat >/usr/local/nginx/ssl/$url.key<<-EOP
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDWTd6YcRpeAq5e
+ySzZmYLT0F6A5fhd5QU5rI+QKU4PVsTvJ8hy/5WyrKvg7yw7d+kdr6Km+Ckwx7L
GvVsd24PPkPi2Wr6VS2ZYaV3Xh4XHIRTFrWO5yCoYz9wzB7HFRDCr34j9O1Q4J6n
TMHYTChlafsr1d+kBTf9cMilg6FnW7s0/+sMdoP+hZYmN30g+VnCCLGdlSoxYmyy
kZbMLq25xDyFuVbVcREanB5ebKt8YODWQLwZEuq/mffO6uxlf8wjcW2UZikmBiuZ
q7MT3TFC7fUUAWlOCDzGV/4NW5AU4I9IysHuc8FWzFbxcslK6gqSQlhzgiUZiOkE
Em4hlZztAgMBAAECggEAA0+lhw7w+e9fgNWvXzs6NpCwAbcw/07mQZK/7HDPbLNG
pzh/RUR+MUVFUKtqfK8BiSxm127poA9ouCQk6HBe9GAr/dhfTAS0D+jfkjIo07Fr
2k8hQ9bj3QjYMoFg31wUC8yuLaw2MiKfqOo+xigFFBi4r1hzsbh9QTlJzFmLN/TT
sjaEQf2clvtJ4Re8kq+rSEuYWYOFGk6CkTnQYaPLAXTlNZy8oImJYLdCJ0QUvQM7
yjJ1eHi28MS4yr93G2C4aVvXIcDy7fWqxfEjkkAzQbRkdAw94unHgSAZ3HR0/Mk6
1gBM+fPI9w75PGNDeIFFsVFEhyCSCEBHJZmupSPYMQKBgQD/ZG1JBb7N4KvYmOJ+
sYpjqAY7VCViVUUWFGeGTc6pMzMEpu5CckVWtjSM589CoqBHDltufJlNVfL2gPod
CiAV/xlOhTGvaEqoPbMJ5vgO+T65HBN94svIOk/IIRitkEPttJ5XBdVJ5YX+mshg
Yj+mwX+r5cI8zIwk0rNqjTkenQKBgQDW0Gnk9Uj6P6y7U+mxk6w8VLyVkRScL+U+
lSKO318IZv1sv+ZYOJJUrJeNdEe+vj6N6ngQbPYmfKLMGAERuCjslVUnMGNZISvP
pAv/hQ9lGSBvny7OKHigOXXKNT7VT1wRf336d4A2YZgvFHLIiGgZ+ECYhfjAVlj3
NXA6VrJ+kQKBgETrvypTqJg6p2V+bLEwDF60e2oLXUNaK5i3zPBLkxfKP1xkCCxa
Vif+Z9QWwrIC3SoPz9DTQzPBnB211Ml9cAc/nn64Jx5lELCyZdyoPg0cajbeQsxY
JhJU2i7x74z3P72oXoqxgku86xo4fxazrOW9lky3ZmGt+av+SHjav61pAoGASkii
BeoIhXlVeyYmbyD485f96t7TuLsbVEvwOmXmEBrFUkD+H83YVG2mruTiFoTlTuAh
CtUTPfXluhwm6oC7rixp2PZztJOy+cfp2j+iNjy9KbxrTCFUrVuRbw6AnvUlimuD
HgULEkMnhEhW9R+umCRv+g6CGckCVOJm39WxPfECgYAbpftynWD0iQctT3NT06l/
blShvTu3453DPcuYMmcciGwZk83538UO5OhUKm7fmWwKgw2Rud7EWEYZZxmlRenQ
kejUeLj7cIwJex/oWOFgSsa6ykHAtkNsATJLZNIqR7wVjf+xwsz2u6O5AoOxUzeb
U5/yi9oqbokDyrjKQTKM6A==
-----END PRIVATE KEY-----

EOP
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
sudo systemctl enable nginx.service
sudo systemctl start nginx.service

echo "###################### Install ok ... ######################"

