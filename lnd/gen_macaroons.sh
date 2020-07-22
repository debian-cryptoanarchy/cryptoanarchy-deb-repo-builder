#!/bin/bash

if [ -z "$_LND_GENMACAROON_FORKED" ];
then
	echo "Forking myself" >&2
	_LND_GENMACAROON_FORKED=42 nohup "$0" "$@" &
	exit 0
fi

lnd_network="$BITCOIN_NETWORK"

. /usr/share/lnd/lib/bash.sh

# Use absolute location to avoid breakage when the original lncli is selected to provide lncli
xlncli="/usr/share/lncli/xlncli"
invoice_readonly_macaroon_path="/var/lib/lnd-system-$lnd_network/invoice/invoice+readonly.macaroon"
tmp_invoice_readonly_macaroon_path="$invoice_readonly_macaroon_path.tmp"

echo "Waiting for LND to initialize" >&2
lnd_wait_init

echo "Waiting for LND to unlock" >&2
while :;
do
	"$xlncli" getinfo &>/dev/null && break
done

echo "Preparing macaroon temp file" >&2
echo -n > "$tmp_invoice_readonly_macaroon_path" || exit 1
chgrp lnd-system-mainnet-readonly "$tmp_invoice_readonly_macaroon_path" || exit 1
chmod 640 "$tmp_invoice_readonly_macaroon_path" || exit 1

echo "Baking macaroon" >&2
"$xlncli" bakemacaroon 'info:read' 'onchain:read' 'offchain:read' 'address:read' 'message:read' 'peers:read' 'signer:read' 'invoices:read' 'invoices:write' 'address:write' | xxd -p -r > "$tmp_invoice_readonly_macaroon_path" || exit 1
sync "$tmp_invoice_readonly_macaroon_path"

echo "Committing macaroon" >&2
mv "$tmp_invoice_readonly_macaroon_path" "$invoice_readonly_macaroon_path"
echo "Macaroon generated" >&2
