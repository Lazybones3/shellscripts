#!/bin/bash

if [ `id -u` -ne 0 ];then
    echo "Error:The script must bu run as root!"
    exit 1
fi

# 安装NeoVim
INSTALL_PATH=$(pwd)

if [ ! -f "nvim-linux64.tar.gz" ];then
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz
fi

tar xzvf nvim-linux64.tar.gz

echo "export PATH=$INSTALL_PATH/nvim-linux64/bin:\$PATH" >> /etc/profile
source /etc/profile

# 安装字体
apt install zip fontconfig -y

if [ ! -f "JetBrainsMono.zip" ];then
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
fi

unzip JetBrainsMono.zip -d /usr/local/share/fonts/JetBrainsMono/
fc-cache -fv

rm -f nvim-linux64.tar.gz JetBrainsMono.zip
