#!/bin/bash

REPO_RAW="https://raw.githubusercontent.com/SCBuergel/ETHaaS/main/"

create_user(){
	sudo adduser --disabled-password --home /home/"$1" --shell /bin/bash --gecos "" "$1"
}

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
		create_user $1

	elif [[ "$1" == "nethermind" ]]
	then
		echo "setting up nethermind as a service"
		create_user $1
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

	elif [[ "$1" == "erigon" ]]
	then
		echo "setting up erigon as a service"
		create_user $1
		cd /home/$1
		git clone --branch stable --single-branch https://github.com/ledgerwatch/erigon.git
		cd erigon
		make erigon

	else
		echo "please pass the client name as a parameter, e.g. 'geth' or 'nethermind'"
		exit 1
	fi

	wget "$REPO_RAW""$1".service
	sudo mv "$1".service /etc/systemd/system/
	sudo systemctl enable "$1"
	sudo systemctl start "$1"

fi
