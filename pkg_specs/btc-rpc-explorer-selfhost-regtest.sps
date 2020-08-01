name = "btc-rpc-explorer-selfhost-regtest"
extends = "btc-rpc-explorer-regtest"
replaces = false
summary = "Integration of btc-rpc-explorer into nginx"
depends = ["selfhost (>=0.1.5)", "selfhost (<<0.2.0)"]

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.BTCEXP_BASE_PATH]
type = "string"
default = "/btc-explorer-rt"
priority = "medium"
summary = "Web prefix of web path to BTC RPC Explorer"

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf"]
format = "yaml"
with_header = true

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf".evars.btc-rpc-explorer-selfhost-regtest.BTCEXP_BASE_PATH]
name = "root_path"

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf".evars.btc-rpc-explorer-regtest.BTCEXP_PORT]
name = "port"

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf".hvars.rewrite]
type = "bool"
constant = "true"
