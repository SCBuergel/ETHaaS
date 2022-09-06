# ETHaaS
ETHaaS allows you to set up an Ethereum client on your Unix system as a service.

## Installation
Just download the shell script and run it, pass the desired client name as a parameter (currently supported `geth` and `nethermind`):
```
wget https://github.com/SCBuergel/eth-as-a-service/blob/main/ETHaaS.sh
./ETHaaS.sh nethermind
```

### What does this do?
ETHaaS will
1. Create a new user with the same name as the client, e.g. `nethermind`
2. Download and install the latest version of the client, note that for nethermind the AMD64 version is installed. If you receive an error and need to run the ARM version, just update the installer script accordingly.
3. Create a system service with the same name as the client, e.g. `nethermind.service`
4. Start the service which will start the Ethereum client. The client is configured to use the home directory of the user that was created in step (1)

## Check that all is up and running
If you don't see an error message, all should be running fine.

You can check that you see the service in the list of services via
```
systemctl list-units --all --type=service --no-pager
```

Check the output of the service via
```
journalctl -f -u nethermind.service
```

## Remove user & service
If you don't want to use the service anymore you can remove it by e.g. (use the name of the client)
1. Stop service
```
sudo systemctl stop nethermind
```
2. Delete service file
```
sudo rm /etc/systemd/system/nethermind.service
```
3. Delete user and home directory (WARNING: This will also delete the chain data file which takes a long time to download if you want to start again!)
```
sudo deluser --remove-home nethermind
```

