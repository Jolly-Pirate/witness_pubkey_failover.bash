## Witness pubkey failover script

as Witness it is recommended to run a hot backup server, synced and running with witness configuration, and using additional pubkey/privkey pair.

if the script identifies that additional missed blocks threshold is reached, it is updating the witness's pubkey to use the defined backup block signing pubkey (defined in the script).

it provides automatic failover, without failback.
the script exits after updating the public key.

*** the script does not monitor the witness servers.

### Requirements
* a local (not on the witness Server) steemd, and a cli wallet running with  
  ```
   $ ./cli_wallet -r127.0.0.1:8090 --rpc-http-allowip 127.0.0.1
  ```   
* 2 witness servers, one primary and other secondary, using different pubkey/privkey pair.
* curl installed (in Ubuntu: sudo apt-get install curl)

### Configuration

edit the variables in the script to match your configuration. make sure all the values are correct.

