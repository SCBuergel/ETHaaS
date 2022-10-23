#!/bin/bash

REPO_RAW="https://raw.githubusercontent.com/SCBuergel/ETHaaS/main/"

create_user(){
	sudo adduser --disabled-password --home /home/"$1" --shell /bin/bash --gecos "" "$1"
}

tmp_dir="ETHaaS_TEMP"
command_not_found="please enter a command as first parameter, e.g. 'add' or 'remove'"
client_not_found="please pass the client name as second arameter, e.g. 'geth' or 'nethermind'"

if [[ -z $1 ]]
then
	echo "$command_not_found"
	exit 1
fi
if [[ -z $2 ]]
then
	echo "$client_not_found"
	exit 1
fi

if [[ "$1" == "add" ]]
then
	if [[ "$2" == "geth" ]]
	then
		echo "setting up geth as a service"
		sudo add-apt-repository -y ppa:ethereum/ethereum
		sudo apt update
		sudo apt install ethereum -y
		create_user $2

	elif [[ "$2" == "nethermind" ]]
	then
		echo "setting up nethermind as a service"
		create_user $2
		mkdir $tmp_dir
		cd $tmp_dir
		wget -O- https://api.github.com/repos/NethermindEth/nethermind/releases/latest | grep nethermind-linux-amd64 | grep browser_download_url | sed "/\"browser_download_url\": \"/s///" | sed "/\"/s///" | xargs wget
		sudo unzip *.zip -d /home/$2
		cd ..
		rm -rf $tmp_dir
		sudo echo '
		NETHERMIND_CONFIG="mainnet"
		NETHERMIND_JSONRPCCONFIG_ENABLED=true
		NETHERMIND_JSONRPCCONFIG_HOST="0.0.0.0"
		NETHERMIND_HEALTHCHECKSCONFIG_ENABLED="true"
		' | sudo tee /home/$2/.env
		sudo bash -c 'echo "nethermind soft nofile 1000000" > /etc/security/limits.d/nethermind.conf'
		sudo bash -c 'echo "nethermind hard nofile 1000000" >> /etc/security/limits.d/nethermind.conf'

	elif [[ "$2" == "erigon" ]]
	then
		echo "setting up erigon as a service"
		create_user $2
		mkdir $tmp_dir
		cd $tmp_dir
		git clone --branch stable --single-branch https://github.com/ledgerwatch/erigon.git
		cd erigon
		# TODO: install go if it's not available
		make erigon
		cp build/bin/erigon /usr/bin
		cd ../..
		rm -rf $tmp_dir

	else
		echo "$client_not_found"
		exit 1
	fi

	wget "$REPO_RAW""$2".service
	sudo mv "$2".service /etc/systemd/system/
	sudo systemctl enable "$2"
	sudo systemctl start "$2"

elif [[ "$1" == "remove" ]]
then
	sudo systemctl stop $2
	sudo systemctl disable $2
	sudo rm /etc/systemd/system/"$2".service
	sudo deluser --remove-home $2
	if [[ "$2" == "geth" ]]
	then
		echo "removing geth service"
		sudo add-apt-repository --remove ppa:ethereum/ethereum -y
		sudo apt purge ethereum -y
	elif [[ "$2" == "nethermind" ]]
	then
		echo "removing nethermind service"
		sudo rm /etc/security/limits.d/nethermind.conf
	elif [[ "$2" == "erigon" ]]
	then
		echo "removing erigon service"
	else
		echo "$client_not_found"
	fi

else
	echo "$command_not_found"
fi
