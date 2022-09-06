#!/bin/bash

if [[ -z $1 ]]
then
  echo "please pass the client name as a parameter, e.g. 'geth' or 'nethermind'"
else

	if [[ "$1" == "geth" ]]
	then
		echo "setting up geth as a service"
		sudo add-apt-repository -y ppa:ethereum/ethereum
		sudo apt update
		sudo apt install ethereum -y
		sudo adduser --disabled-password --home /home/geth --shell /bin/bash --gecos "" geth
		wget https://raw.githubusercontent.com/SCBuergel/eth-as-a-service/main/geth.service
		sudo mv geth.service /etc/systemd/system/
		sudo systemctl enable geth
		sudo systemctl start geth

	elif [[ "$1" == "nethermind" ]]
	then
		echo "setting up nethermind as a service"
  	sudo adduser --disabled-password --home /home/nethermind --shell /bin/bash --gecos "" nethermind
  	wget -O- https://api.github.com/repos/NethermindEth/nethermind/releases/latest | grep nethermind-linux-amd64 | grep browser_download_url | sed "/\"browser_download_url\": \"/s///" | sed "/\"/s///" | xargs wget
  	sudo unzip *.zip -d /home/nethermind
  	sudo echo '
  	NETHERMIND_CONFIG="mainnet"
  	NETHERMIND_JSONRPCCONFIG_ENABLED=true
  	NETHERMIND_JSONRPCCONFIG_HOST="0.0.0.0"
  	NETHERMIND_HEALTHCHECKSCONFIG_ENABLED="true"
  	' | sudo tee /home/nethermind/.env
  	sudo bash -c 'echo "nethermind soft nofile 1000000" > /etc/security/limits.d/nethermind.conf'
  	sudo bash -c 'echo "nethermind hard nofile 1000000" >> /etc/security/limits.d/nethermind.conf'
  	wget https://raw.githubusercontent.com/SCBuergel/eth-as-a-service/main/nethermind.service
  	sudo mv nethermind.service /etc/systemd/system/
  	sudo systemctl enable nethermind
  	sudo systemctl start nethermind

	else
		echo "please pass the client name as a parameter, e.g. 'geth' or 'nethermind'"
	fi
fi
