name = "btcpayserver-lnp-system-regtest"
extends = "btcpayserver-system-regtest"
depends_on_extended = true
summary = "Package integrating LND into BTCPayServer"
depends = ["btcpayserver-system-regtest", "lnd-genmacaroon-system-regtest", "openssl"]

[config."conf.d/lnd.conf"]
format = "plain"

[config."conf.d/lnd.conf".evars.lnd-system-regtest.rest_port]
store = false

[config."conf.d/lnd.conf".evars.lnd-system-regtest.tlscertpath]
store = false

[config."conf.d/lnd.conf".hvars."btc.lightning"]
type = "string"
script = "echo \"type=lnd-rest;server=https://127.0.0.1:${CONFIG[\"lnd-system-regtest/rest_port\"]}/;macaroonfilepath=/var/lib/lnd-system-regtest/invoice/invoice+readonly.macaroon;certthumbprint=`openssl x509 -noout -fingerprint -sha256 -inform pem -in ${CONFIG[\"lnd-system-regtest/tlscertpath\"]} | sed 's/^.*=//' | tr -d ':'`\""

[config."conf.d/lnd.conf".postprocess]
command = ["usermod", "-a", "-G", "lnd-system-regtest-readonly,lnd-system-regtest-invoice", "btcpayserver-system-regtest"]
