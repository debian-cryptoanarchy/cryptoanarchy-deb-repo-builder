# This is NOT a public API!
# This is NOT a config - do NOT edit!

conf_dir="/etc/bitcoin-$network"
main_conf_file="$conf_dir/bitcoin.conf"
state_dir="`grep '^datadir=' "$main_conf_file" | sed 's/^datadir=//'`"
chain_mode_file="$conf_dir/chain_mode"
prev_chain_mode_file="$conf_dir/prev_chain_mode"
prev_chain_mode_tmp_file="$prev_chain_mode_file.tmp"
needs_reindex_marker_file="$state_dir/needs_reindex"

if [ "$network" '!=' 'mainnet' ];
then
	subdir="/$network"
else
	subdir=""
fi

log_file="/var/log/bitcoin-$network$subdir/debug.log"
