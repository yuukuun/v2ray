###安装acme.sh
wget -O -  https://get.acme.sh | sh

###安装证书###
echo "1.阿里云 DNS"
echo "2.CloudFlare DNS"
read -p "请选择1-2：" num
case num in
1) 
	dns="dns_ali"
	read -p "请输入阿里云Ali_Key：" Ali_Key
	read -p "请输入阿里云Ali_Secret：" Ali_Secret
	export $Ali_Key && echo $Ali_Key >> ~/.bashrc
	export $Ali_Secret && echo $Ali_Secret >> ~/.bashrc
;;
2)
	dns="dns_cf"
	read -p "请输入CloudFlare CF_Key：" CF_Key
	read -p "请输入CloudFlare CF_Email：" CF_Email
	export CF_Key && echo $CF_Key >> ~/.bashrc
	export CF_Email && echo $CF_Email >> ~/.bashrc
;; 
*) echo "输入错误！" ;;	
esac
acme.sh --issue --dns $dns -d $url -d  "*.$url"

###拷贝证书到nginx目录###
acme.sh --install-cert -d  $url \
--key-file       /usr/local/nginx/ssl/$url/$url.key  \
--fullchain-file /usr/local/nginx/ssl/$url/fullchain.cer \
--reloadcmd     "/usr/local/nginx/sbin/nginx -s reload"
sudo systemctl start nginx.servic
sudo systemctl enable nginx.service

###自动续费###
0 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" >> /var/log/acme.sh-auto-renew.log