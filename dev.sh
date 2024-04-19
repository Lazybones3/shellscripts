#!/bin/bash

PUB_KEY=""

sudo apt update
sudo apt install build-essential cmake pkg-config git

# ssh
if [ -z $PUB_KEY ]; then
    echo "Please set a public key for ssh!"
    exit 1;
fi

sudo apt install openssh-server

if [ ! -d "~/.ssh" ]; then
    mkdir ~/.ssh
fi
echo "$PUB_KEY" >> ~/.ssh/authorized_keys
sudo cat > /etc/ssh/sshd_config <<-EOF
PermitRootLogin yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
EOF

sudo systemctl restart sshd
