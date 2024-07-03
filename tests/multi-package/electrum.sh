#!/bin/bash

set -e

test_dir="$(realpath "$(dirname "$0")/..")"

. "$test_dir/common.sh"

preload_config

sudo apt-get install -y bitcoin-regtest bitcoin-cli electrs electrum-trustless-regtest jq libfuse2 fuse3

# Heavily inspired by the one in electrs itself

cleanup() {
  trap - SIGTERM SIGINT
  set +eo pipefail
  jobs
  for j in `jobs -rp`
  do
  	kill $j
  	wait $j
  done
}
trap cleanup SIGINT SIGTERM EXIT

BTC="sudo bitcoin-cli -chain=regtest"
ELECTRUM="electrum-trustless-regtest"
EL="electrum --regtest"

tail_log() {
	tail -n +0 -F $1 || true
}

$BTC -rpcwait getblockcount > /dev/null

echo "Creating Electrum `electrum version --offline` wallet..."
WALLET=`$EL --offline create --seed_type=segwit`
MINING_ADDR=`$EL --offline getunusedaddress`

$BTC generatetoaddress 110 $MINING_ADDR > /dev/null
echo `$BTC getblockchaininfo | jq -r '"Generated \(.blocks) regtest blocks (\(.size_on_disk/1e3) kB)"'` to $MINING_ADDR

TIP=`$BTC getbestblockhash`

wget -O metrics.txt http://localhost:24224

$ELECTRUM daemon -vDEBUG 2> ~/electrum-debug.log &
ELECTRUM_PID=$!
tail_log ~/electrum-debug.log | grep -m1 "connection established"
$EL getinfo | jq .

echo "Loading Electrum wallet..."
$EL load_wallet

echo "Running integration tests:"

echo " * getbalance"
test "`$EL getbalance | jq -c .`" == '{"confirmed":"550","unmatured":"4950"}'

echo " * getunusedaddress"
NEW_ADDR=`$EL getunusedaddress`

echo " * payto & broadcast"
TXID=$($EL broadcast $($EL payto $NEW_ADDR 123 --fee 0.001 --password=''))

echo " * get_tx_status"
test "`$EL get_tx_status $TXID | jq -c .`" == '{"confirmations":0}'

echo " * getaddresshistory"
test "`$EL getaddresshistory $NEW_ADDR | jq -c .`" == "[{\"fee\":100000,\"height\":0,\"tx_hash\":\"$TXID\"}]"

echo " * getbalance"
test "`$EL getbalance | jq -c .`" == '{"confirmed":"549.999","unmatured":"4950"}'

echo "Generating bitcoin block..."
$BTC generatetoaddress 1 $MINING_ADDR > /dev/null
$BTC getblockcount > /dev/null

echo " * wait for new block"
sudo killall -USR1 electrs  # notify server to index new block
tail_log ~/electrum-debug.log | grep -m1 "verified $TXID" > /dev/null

echo " * get_tx_status"
test "`$EL get_tx_status $TXID | jq -c .`" == '{"confirmations":1}'

echo " * getaddresshistory"
test "`$EL getaddresshistory $NEW_ADDR | jq -c .`" == "[{\"height\":111,\"tx_hash\":\"$TXID\"}]"

echo " * getbalance"
test "`$EL getbalance | jq -c .`" == '{"confirmed":"599.999","unmatured":"4950.001"}'

echo "Electrum `$EL stop`"  # disconnect wallet
wait $ELECTRUM_PID

echo "=== PASSED ==="
