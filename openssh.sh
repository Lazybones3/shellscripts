#!/bin/bash

PUB_KEY=""
CURRENT_HOME=$HOME

if [ -z "$PUB_KEY" ]; then
        echo "Please set a public key for ssh!"
        exit 1;
fi

sudo apt update
sudo apt install build-essential cmake pkg-config git

# ssh
sudo apt install openssh-server

if [ ! -d "$CURRENT_HOME/.ssh" ]; then
	mkdir $CURRENT_HOME/.ssh
fi

if [ ! -f "$CURRENT_HOME/.ssh/authorized_keys" ]; then
	touch $CURRENT_HOME/.ssh/authorized_keys
fi

AUTHORIZED_KEYS="$CURRENT_HOME/.ssh/authorized_keys"
grep -q "$PUB_KEY" $AUTHORIZED_KEYS
if [ $? -ne 0 ]; then
	echo "$PUB_KEY" >> $AUTHORIZED_KEYS
fi

MY_CONFIG="# MyOpensshConfigration"
SSHD_CONFIG="/etc/ssh/sshd_config"
grep -q "$MY_CONFIG" $SSHD_CONFIG
if [ $? -ne 0 ]; then
	echo "cat >> $SSHD_CONFIG <<-EOF
	$MY_CONFIG
	PermitRootLogin yes
	PubkeyAuthentication yes
	AuthorizedKeysFile .ssh/authorized_keys
	PasswordAuthentication yes
	EOF" | sudo sh
fi

sudo systemctl restart sshd
