#Requesting the Input values
echo "================================================================================================================================"
echo "Please follow the insructions below"
echo "================================================================================================================================"
echo "Start entering values one by one as system keeps ask"
echo "================================================================================================================================"

read -p "Enter name of your node (a-z,A-Z,-) : " name
read -p "Enter Your Infura Id : " infura
read -p "Enter Your Etherium Wallet Address : " eth
read -p "Enter Your Etherium Wallet Passwd : " passwd
read -p "Enter Your keyfile content : " keyfile
read -p "Enter port number (default 3319) : " port
read -p "Do you want to start container by now? (type 'y' for yes)" cond

#Install docker & ufw & curl
apt-get update
sleep 5
apt-get install curl
sleep 5
apt-get install ufw
sleep 5
apt-get remove docker docker-engine docker.io
sleep 5
apt install docker.io curl -y
sleep 5
systemctl start docker
sleep 1
systemctl enable docker
sleep 1

#Setup the firewall rules
ufw allow 22/tcp
sleep 1
ufw allow $port/tcp
sleep 1
yes | ufw enable
sleep 1

#Creating project directories
mkdir -p /root/$name/
mkdir -p /root/$name/config
mkdir -p /root/$name/persistence

#Writing keyfile to disk
echo $keyfile >> /root/$name/config/keyfile

#Writing  /root/$name/config/config.toml file
echo '#Connection details of ethereum blockchain.' >> /root/$name/config/config.toml
echo '[ethereum]' >> /root/$name/config/config.toml
echo ' URL = "wss://ropsten.infura.io/ws/v3/'$infura'"' >> /root/$name/config/config.toml
echo ' URLRPC = "https://ropsten.infura.io/v3/'$infura'"' >> /root/$name/config/config.toml
echo '# Keep operator Ethereum account.' >> /root/$name/config/config.toml
echo '[ethereum.account]' >> /root/$name/config/config.toml
echo ' Address = "'$eth'"' >> /root/$name/config/config.toml
echo ' KeyFile = "/mnt/keep-ecdsa-client/config/keyfile"' >> /root/$name/config/config.toml
echo '# Keep contract addresses configuration.' >> /root/$name/config/config.toml
echo '[ethereum.ContractAddresses]' >> /root/$name/config/config.toml
echo ' BondedECDSAKeepFactory = "0xe7BF8421fBE80c3Bf67082370D86C8D81D1D77F4"' >> /root/$name/config/config.toml
echo '[SanctionedApplications] ' >> /root/$name/config/config.toml
echo '  Addresses = [ ' >> /root/$name/config/config.toml
echo '     "0x14dC06F762E7f4a756825c1A1dA569b3180153cB" ' >> /root/$name/config/config.toml
echo '   ] ' >> /root/$name/config/config.toml
echo '# Keep network configuration.' >> /root/$name/config/config.toml
echo '[LibP2P]' >> /root/$name/config/config.toml
echo ' Peers = ["/dns4/bootstrap-1.ecdsa.keep.test.boar.network/tcp/4001/ipfs/16Uiu2HAmPFXDaeGWtnzd8s39NsaQguoWtKi77834A6xwYqeicq6N",
"/dns4/ecdsa-2.test.keep.network/tcp/3919/ipfs/16Uiu2HAmNNuCp45z5bgB8KiTHv1vHTNAVbBgxxtTFGAndageo9Dp",
"/dns4/ecdsa-3.test.keep.network/tcp/3919/ipfs/16Uiu2HAm8KJX32kr3eYUhDuzwTucSfAfspnjnXNf9veVhB12t6Vf"]' >> /root/$name/config/config.toml
echo ' Port = '$port'' >> /root/$name/config/config.toml
echo '[Storage]' >> /root/$name/config/config.toml
echo ' DataDir = "/mnt/keep-ecdsa-client/persistence"' >> /root/$name/config/config.toml
echo '[TSS] ' >> /root/$name/config/config.toml
echo '  PreParamsGenerationTimeout = "2m30s"' >> /root/$name/config/config.toml

#Creating $name.sh script to create container
echo 'docker run -d \' >> /root/$name.sh
echo '--entrypoint keep-ecdsa \' >> /root/$name.sh 
echo '--restart always \' >> /root/$name.sh
echo '--volume /root/'$name'/persistence:/mnt/keep-ecdsa-client/persistence \' >> /root/$name.sh
echo '--volume /root/'$name'/config:/mnt/keep-ecdsa-client/config \' >> /root/$name.sh
echo '--env KEEP_ETHEREUM_PASSWORD='$passwd' \' >> /root/$name.sh
echo '--env LOG_LEVEL=debug \' >> /root/$name.sh
echo '--name '$name' \' >> /root/$name.sh
echo '-p '$port':'$port' \' >> /root/$name.sh
echo 'keepnetwork/keep-ecdsa-client:v1.1.2-rc --config /mnt/keep-ecdsa-client/config/config.toml start' >> /root/$name.sh

#Making script executable
chmod +x /root/$name.sh

if [ "$cond" = "y" ]; then 
    /root/./$name.sh
    rm /root/$name.sh #Killing him few moments later
else 
    echo "For creating and running your node later type ./$name.sh command."
fi
