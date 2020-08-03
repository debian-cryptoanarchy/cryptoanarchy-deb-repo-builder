name = "nbxplorer-mainnet"
bin_package = "nbxplorer"
binary = "/usr/bin/nbxplorer"
conf_param = "--conf="
user = { group = true, create = { home = true } }
depends = ["bitcoin-mainnet (>= 0.20.0-6)", "bitcoin-timechain-mainnet"]
summary = "A minimalist UTXO tracker for HD Wallets."
extra_service_config = """
Restart=always
"""

[extra_groups."nbxplorer-mainnet-access-rpc"]
create = true

[config."nbxplorer.conf"]
format = "plain"
public = true
cat_dir = "conf.d"

[config."nbxplorer.conf".ivars.datadir]
type = "path"
file_type = "dir"
default = "/var/lib/nbxplorer-mainnet"
create = { mode = 750, owner = "nbxplorer-mainnet", group = "nbxplorer-mainnet-access-rpc" }
priority = "low"
summary = "NBXplorer data directory"

[config."nbxplorer.conf".ivars."port"]
type = "bind_port"
default = "24445"
priority = "low"
summary = "The port NBXplorer should listen on"

# Separate file to deflect possible future danger.
[config."conf.d/bitcoin_iface.conf"]
format = "plain"

[config."conf.d/bitcoin_iface.conf".hvars."btc.rpc.auth"]
type = "string"
constant = "public:public"

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-mainnet.p2p_bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."btc.node.endpoint"]
type = "string"
script = "echo \"127.0.0.1:${CONFIG[\"bitcoin-mainnet/p2p_bind_port\"]}\""

[config."conf.d/bitcoin_iface.conf".hvars."chains"]
type = "string"
constant = "btc"

[config."conf.d/bitcoin_iface.conf".hvars."mainnet"]
type = "bool"
constant = "1"

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-rpc-proxy-mainnet.bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."btc.rpc.url"]
type = "string"
script = "echo \"http://127.0.0.1:${CONFIG[\"bitcoin-rpc-proxy-mainnet/bind_port\"]}/\""

# This is useful for nbxplorer and I'm not sure if it should be configurable.
# If you read this because you'd like to configure it, please file an issue and describe
# your use case.
[config."conf.d/bitcoin_iface.conf".hvars.whitelist]
type = "string"
constant = "127.0.0.1"

[config."conf.d/bitcoin_iface.conf".hvars."btc.hastxindex"]
type = "bool"
script = "grep -q txindex=1 /etc/bitcoin-mainnet/chain_mode && echo true || echo false"
