name = "btc-rpc-explorer-mainnet"
bin_package = "btc-rpc-explorer"
binary = "/usr/bin/btc-rpc-explorer"
user = { group = true, create = { home = true } }
summary = "Simple, database-free Bitcoin blockchain explorer (mainnet)"
depends = ["bitcoin-timechain-mainnet (>= 0.1.0-5)", "bitcoin-txindex-mainnet"]
recommends = ["btc-rpc-explorer-selfhost-mainnet"]
suggests = ["electrs-mainnet"]
extra_service_config = """
Restart=always
EnvironmentFile=/etc/btc-rpc-explorer-mainnet/btc-rpc-explorer.conf
RuntimeDirectory=btc-rpc-explorer-mainnet
RuntimeDirectoryMode=755
"""

[config."btc-rpc-explorer.conf"]
format = "plain"
cat_dir = "conf.d"

[config."btc-rpc-explorer.conf".ivars.BTCEXP_PORT]
type = "bind_port"
default = "5000"
priority = "low"
summary = "Bind port for BTC RPC Explorer"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BITCOIND_USER]
type = "string"
constant = "public"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BITCOIND_PASS]
type = "string"
constant = "public"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BITCOIND_HOST]
type = "string"
constant = "127.0.0.1"

[config."btc-rpc-explorer.conf".evars.bitcoin-rpc-proxy-mainnet.bind_port]
name = "BTCEXP_BITCOIND_PORT"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_ADDRESS_API]
type = "string"
script = """
if [ -r "/etc/electrs-mainnet/conf.d/interface.toml" ];
then
    echo electrumx
fi
"""

[config."btc-rpc-explorer.conf".hvars.BTCEXP_ELECTRUMX_SERVERS]
type = "string"
script = """
if [ -r "/etc/electrs-mainnet/conf.d/interface.toml" ];
then
    echo "tcp://127.0.0.1:`grep '^ *electrum_rpc_addr' "/etc/electrs-mainnet/conf.d/interface.toml" | sed 's/^ *electrum_rpc_addr *= *"[^:]*:\\([0-9]*\\)".*$/\\1/'`"
fi
"""
ignore_empty = true

[config."btc-rpc-explorer.conf".ivars.BTCEXP_PRIVACY_MODE]
type = "bool"
default = "true"
priority = "medium"
summary = "Enable privacy mode of BTC RPC Explorer? (No exchange rates)"

[config."btc-rpc-explorer.conf".ivars.http_password]
type = "string"
default = ""
priority = "medium"
summary = "HTTP password for BTC RPC Explorer (empty = generate random)"
store = false

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BASIC_AUTH_PASSWORD]
type = "string"
script = """
if [ -n "${CONFIG[\"btc-rpc-explorer-mainnet/http_password\"]}" ];
then
    echo "${CONFIG[\"btc-rpc-explorer-mainnet/http_password\"]}"
else
    head -c 18 /dev/urandom | base64 | tr -d '\\n'
fi
"""
