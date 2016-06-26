#!/bin/bash

account="accoutname"
init_misses=113  #witness current total_misses count
misses_failover_count=2   #misses count threshold for failing over to backup pubkey
backup_pub_signing_key=STMbackuppubkey
wallet="http://localhost:8090/rpc"  #steemd's rpc
wallet_passphrase="walletpassphrase"
props='{"account_creation_fee":"10.000 STEEM","maximum_block_size":131072,"sbd_interest_rate":1000}'
witness_url="https://steemit.com/witness-category/@accountname/witness-post"  #edit to match your witness URL/CV

##

function check_misses {
  misses="$(curl --data-ascii '{"id":0,"method":"get_witness","params":["'"$account"'"]}' \
			-s "$wallet" \
		     | sed "s/,/\n/g" \
		     | grep "total_missed" \
		     | cut -d":" -f 2)"
  echo $misses
}

misses=`check_misses`

if [ $misses -ne $init_misses ] ; then
  echo "failed for fetch misses from steemd, \$init_misses is not equal to \$misses"
  exit 1
fi

echo "[`date`] init misses: $init_misses"

while true ; do 
  misses=`check_misses`
  if [ -z "`echo $misses | grep -E '[[:digit:]]'`" ] ; then
    echo "[`date`] failed to fetch misses from steemd (not a number)"
    sleep 10s
    continue
  fi
  echo "[`date`] misses: $misses"
  if [ $(($misses-$init_misses)) -ge $misses_failover_count ] ; then
     echo "[`date`] FAILOVER updating witness public signing key"
     curl -H "content-type: application/json" -X POST -d "{\"id\":0,\"method\":\"unlock\",\"params\":[\"$wallet_passphrase\"]}" $wallet
     curl -H "content-type: application/json" -X POST -d "{\"id\":0,\"method\":\"update_witness\",\"params\":[\"$account\",\"$witness_url\",\"$backup_pub_signing_key\",$props,true]}" $wallet 2>/dev/null
     curl -H "content-type: application/json" -X POST -d "{\"id\":0,\"method\":\"lock\",\"params\":[]}" $wallet
     exit 2
  fi
  sleep 10s
done
