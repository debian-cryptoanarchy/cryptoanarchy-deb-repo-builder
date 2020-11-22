name = "btcpayserver-lnp-system-@variant"
extends = "btcpayserver-system-@variant"
depends_on_extended = true
summary = "Package integrating LND into BTCPayServer ({variant})"
depends = ["btcpayserver-system-{variant}", "lnd-genmacaroon-system-{variant}", "openssl"]

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

[config."conf.d/lnd.conf".hvars."certthumbprint"]
type = "string"
store = false
script = "openssl x509 -noout -fingerprint -sha256 -inform pem -in ${{CONFIG[\"lnd-system-{variant}/tlscertpath\"]}} | sed 's/^.*=//' | tr -d ':'"

[config."conf.d/lnd.conf".hvars."btc.lightning"]
type = "string"
template = "type=lnd-rest;server=https://127.0.0.1:{lnd-system-@variant/rest_port}/;macaroonfilepath=/var/lib/lnd-system-{variant}/invoice/invoice+readonly.macaroon;certthumbprint={/certthumbprint}"
