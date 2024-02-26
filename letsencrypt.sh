apt install python3 python3-venv libaugeas0 python3-pip -y
apt-get remove certbot
pip3 install certbot
pip3 install pyOpenSSL==23.1.1
certbot certonly --standalone -d $DOMAIN_NAME

echo "finish install letsencry"