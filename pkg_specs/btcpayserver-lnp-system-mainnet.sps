name = "btcpayserver-lnp-system-mainnet"
extends = "btcpayserver-system-mainnet"
depends_on_extended = true
summary = "Package integrating LND into BTCPayServer"
depends = ["btcpayserver-system-mainnet", "lnd-genmacaroon-system-mainnet", "openssl"]

[config."conf.d/lnd.conf"]
format = "plain"

[config."conf.d/lnd.conf".evars.lnd-system-mainnet.rest_port]
store = false

[config."conf.d/lnd.conf".evars.lnd-system-mainnet.tlscertpath]
store = false

[config."conf.d/lnd.conf".hvars."btc.lightning"]
type = "string"
script = "echo \"type=lnd-rest;server=https://127.0.0.1:${CONFIG[\"lnd-system-mainnet/rest_port\"]}/;macaroonfilepath=/var/lib/lnd-system-mainnet/invoice/invoice+readonly.macaroon;certthumbprint=`openssl x509 -noout -fingerprint -sha256 -inform pem -in ${CONFIG[\"lnd-system-mainnet/tlscertpath\"]} | sed 's/^.*=//' | tr -d ':'`\""

[config."conf.d/lnd.conf".postprocess]
command = ["usermod", "-a", "-G", "lnd-system-mainnet-readonly,lnd-system-mainnet-invoice", "btcpayserver-system-mainnet"]
