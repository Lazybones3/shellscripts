#!/bin/bash

DOMAIN_NAME=""

echo -n "Please input your domain name: "
read DOMAIN_NAME
if [ -z $DOMAIN_NAME ];
then
    echo "Domain name cannot be empty."
    exit 1;
fi
echo "Your domain name is $DOMAIN_NAME."

PORT=10000
UUID=$(cat /proc/sys/kernel/random/uuid)
WS_PATH="/news"

echo -n "Do you want to install nginx? [y/n] "
read is_install_nginx
if [ "$is_install_nginx" = "y" ] || [ "$is_install_nginx" = "yes" ];
then
    apt install nginx -y
fi

cat > /etc/nginx/conf.d/nginx-v2ray.conf <<EOF
server {
  listen 443 ssl;
  listen [::]:443 ssl;
  
  ssl_certificate       /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
  ssl_certificate_key   /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:MozSSL:10m;
  ssl_session_tickets off;
  
  ssl_protocols         TLSv1.2 TLSv1.3;
  ssl_ciphers           ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_prefer_server_ciphers off;
  
  server_name           $DOMAIN_NAME;
  location $WS_PATH {
    if (\$http_upgrade != "websocket") {
        return 404;
    }
    proxy_redirect off;
    proxy_pass http://127.0.0.1:$PORT;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    # Show real IP in v2ray access.log
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  }
}
EOF

nginx -s quit
nginx -c /etc/nginx/nginx.conf

echo -n "Do you want to install v2ray server? [y/n] "
read is_install_v2ray
if [ "$is_install_v2ray" = "y" ] || [ "$is_install_v2ray" = "yes" ];
then
    apt install curl -y
    curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh | bash
fi

cat > /usr/local/etc/v2ray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$WS_PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}

EOF

echo "Install v2ray finished!!!"

echo -n "Do you want to generate client config file? [y/n] "
read is_generate_client
if [ "$is_generate_client" = "n" ] || [ "$is_generate_client" = "no" ];
then
    exit 0
fi

cat > ./client-config.json <<EOF
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      },
      "settings": {
        "auth": "noauth",
        "udp": false
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$DOMAIN_NAME",
            "port": 443,
            "users": [
              {
                "id": "$UUID",
                "alterId": 0
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "$WS_PATH"
        }
      }
    }
  ]
}
EOF
