#!/bin/bash

##获
wget -O -  https://get.acme.sh | sh

acme.sh  --issue -d mgleek.mn -w /usr/local/nginx/html/
#acme.sh --issue -d $url -w /usr/local/nginx/html/

