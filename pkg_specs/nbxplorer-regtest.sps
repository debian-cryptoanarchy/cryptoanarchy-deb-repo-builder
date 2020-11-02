name = "nbxplorer-regtest"
bin_package = "nbxplorer"
binary = "/usr/bin/nbxplorer"
conf_param = "--conf="
user = { group = true, create = { home = true } }
depends = ["bitcoin-regtest (>= 0.20.0-6)", "bitcoin-timechain-regtest", "bitcoin-rpc-proxy (>= 0.1.1-1) | bitcoin-timechain-mainnet (= 0.1.0-9)"]
summary = "A minimalist UTXO tracker for HD Wallets."
extra_service_config = """
Restart=always
"""

[extra_groups."nbxplorer-regtest-access-rpc"]
create = true

[config."nbxplorer.conf"]
format = "plain"
public = true
cat_dir = "conf.d"

[config."nbxplorer.conf".hvars."network"]
type = "string"
constant = "regtest"

[config."nbxplorer.conf".ivars.datadir]
type = "path"
file_type = "dir"
default = "/var/lib/nbxplorer-regtest"
create = { mode = 750, owner = "nbxplorer-regtest", group = "nbxplorer-regtest-access-rpc" }
priority = "low"
summary = "NBXplorer data directory"

[config."nbxplorer.conf".ivars."port"]
type = "bind_port"
default = "24447"
priority = "low"
summary = "The port NBXplorer should listen on"

# Separate file to deflect possible future danger.
[config."conf.d/bitcoin_iface.conf"]
format = "plain"

[config."conf.d/bitcoin_iface.conf".hvars."btc.rpc.auth"]
type = "string"
constant = "public:public"

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-regtest.p2p_bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."btc.node.endpoint"]
type = "string"
script = "echo \"127.0.0.1:${CONFIG[\"bitcoin-regtest/p2p_bind_port\"]}\""

[config."conf.d/bitcoin_iface.conf".hvars."chains"]
type = "string"
constant = "btc"

[config."conf.d/bitcoin_iface.conf".hvars."regtest"]
type = "bool"
constant = "1"

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-rpc-proxy-regtest.bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."btc.rpc.url"]
type = "string"
script = "echo \"http://127.0.0.1:${CONFIG[\"bitcoin-rpc-proxy-regtest/bind_port\"]}/\""

[config."conf.d/bitcoin_iface.conf".hvars."btc.hastxindex"]
type = "bool"
script = "grep -q txindex=1 /etc/bitcoin-regtest/chain_mode && echo true || echo false"
