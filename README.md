# ETHaaS
ETHaaS allows you to set up an Ethereum client on your Unix system as a service.

## Adding a service
Just download the shell script, make it executable and run it, pass the desired client name as a parameter (currently supported `geth`, `nethermind` and `erigon`):
```
wget https://raw.githubusercontent.com/SCBuergel/ETHaaS/main/ETHaaS.sh
chmod +x ETHaaS.sh
./ETHaaS.sh add nethermind
```

### What does this do?
ETHaaS will
1. Create a new user with the same name as the client, e.g. `nethermind`
2. Download and install the latest version of the client, note that for nethermind the AMD64 version is installed. If you receive an error and need to run the ARM version, just update the installer script accordingly.
3. Create a system service with the same name as the client, e.g. `nethermind.service`
4. Start the service which will start the Ethereum client. The client is configured to use the home directory of the user that was created in step (1)

### Check that all is up and running
If you don't see an error message, all should be running fine.

You can check that you see the service in the list of services via
```
systemctl list-units --all --type=service --no-pager
```

Check the output of the service via
```
journalctl -f -u nethermind.service
```

## Remove service

Simply run `ETHaaS` again with the `remove` command, e.g.:
```
./ETHaaS.sh remove nethermind
```

This will unregister the service, remove the executable and also remove the user along with all files

