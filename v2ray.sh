#!/bin/bash

apt update
apt install curl -y
curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh | bash

UUID=$(cat /proc/sys/kernel/random/uuid)
PORT=39999

cat > /usr/local/etc/v2ray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
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
