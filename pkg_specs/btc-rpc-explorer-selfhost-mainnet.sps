name = "btc-rpc-explorer-selfhost-mainnet"
extends = "btc-rpc-explorer-mainnet"
replaces = false
summary = "Integration of btc-rpc-explorer into nginx"
depends = ["selfhost (>=0.1.5)", "selfhost (<<0.2.0)"]

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.BTCEXP_BASE_PATH]
type = "string"
default = "/btc-rpc-explorer"
priority = "medium"
summary = "Web prefix of web path to BTC RPC Explorer"

[config."../selfhost/apps/btc-rpc-explorer-mainnet.conf"]
format = "yaml"
with_header = true

[config."../selfhost/apps/btc-rpc-explorer-mainnet.conf".evars.btc-rpc-explorer-selfhost-mainnet.BTCEXP_BASE_PATH]
name = "root_path"

[config."../selfhost/apps/btc-rpc-explorer-mainnet.conf".evars.btc-rpc-explorer-mainnet.BTCEXP_PORT]
name = "port"

[config."../selfhost/apps/btc-rpc-explorer-mainnet.conf".hvars.rewrite]
type = "bool"
constant = "true"
