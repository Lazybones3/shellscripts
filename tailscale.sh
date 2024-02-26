#!/bin/bash

DOMAIN_NAME=$(cat ./domain.txt)
if [ -z $DOMAIN_NAME ];
then
    echo "Domain name cannot be empty."
    exit 1;
fi
echo "Your domain name is $DOMAIN_NAME."

ENCRYPT_PATH="/etc/letsencrypt/live/$DOMAIN_NAME"

echo -n "Do you want to install letsencrypt? [y/n] "
read is_install_letsencrypt
if [ "$is_install_letsencrypt" = "y" ] || [ "$is_install_letsencrypt" = "yes" ];
then
	source letsencrypt.sh
fi

cp $ENCRYPT_PATH/fullchain.pem $ENCRYPT_PATH/$DOMAIN_NAME.crt
cp $ENCRYPT_PATH/private.pem $ENCRYPT_PATH/$DOMAIN_NAME.key

echo -n "Do you want to install go? [y/n] "
read is_install_go
if [ "$is_install_go" = "y" ] || [ "$is_install_go" = "yes" ];
then
	wget https://golang.google.cn/dl/go1.21.6.linux-amd64.tar.gz
	rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz
	rm -f go1.21.6.linux-amd64.tar.gz
	echo "finish install go"
fi

echo -n "Do you want to install DERP Server? [y/n] "
read is_install_derp
if [ "$is_install_derp" = "y" ] || [ "$is_install_derp" = "yes" ];
then
	/usr/local/go/bin/go install tailscale.com/cmd/derper@main
	cat > /etc/systemd/system/derp.service <<-EOF
	[Unit]
	Description=TS Derper
	After=network.target
	Wants=network.target
	[Service]
	User=root
	Restart=always
	ExecStart=$HOME/go/bin/derper -hostname $DOMAIN_NAME -a :33445 -http-port 33446 -certmode manual -certdir $ENCRYPT_PATH
	RestartPreventExitStatus=1
	[Install]
	WantedBy=multi-user.target
	EOF

	systemctl enable derp
	#systemctl start derp

	echo "finish install DERP Server"
fi

echo "finish all!!!"
