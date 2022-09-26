name = "btcpayserver-lnp-system-@variant"
extends = "btcpayserver-system-@variant"
depends_on_extended = true
summary = "Package integrating LND into BTCPayServer ({variant})"
depends = ["btcpayserver-system-{variant} (>= 1.3.6)", "lnd-genmacaroon-system-{variant}", "openssl"]

[extra_groups."lnd-system-{variant}-readonly"]
create = false

[extra_groups."lnd-system-{variant}-invoice"]
create = false

[config."conf.d/lnd.conf"]
format = "plain"

[config."conf.d/lnd.conf".evars."lnd-system-@variant".rest_port]
store = false

[config."conf.d/lnd.conf".evars."lnd-system-@variant".tlscertpath]
store = false

[config."conf.d/lnd.conf".hvars."btc.lightning"]
type = "string"
template = "type=lnd-rest;server=https://127.0.0.1:{lnd-system-@variant/rest_port}/;macaroonfilepath=/var/lib/lnd-system-{variant}/invoice/invoice+readonly.macaroon;certfilepath=/var/lib/lnd-system-{variant}/public/tls.cert"
