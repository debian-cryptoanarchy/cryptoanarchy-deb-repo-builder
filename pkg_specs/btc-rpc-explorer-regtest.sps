name = "btc-rpc-explorer-regtest"
bin_package = "btc-rpc-explorer"
binary = "/usr/bin/btc-rpc-explorer"
user = { group = true, create = { home = true } }
summary = "Simple, database-free Bitcoin blockchain explorer (regtest)"
depends = ["bitcoin-timechain-regtest (>= 0.1.0-5)", "bitcoin-txindex-regtest"]
conflicts = ["btc-rpc-explorer-selfhost-regtest"]
recommends = ["selfhost (>=0.1.5)", "selfhost (<<0.2.0)"]
extended_by = ["electrs-regtest"]
runtime_dir = { mode = "755" }
extra_service_config = """
Restart=always
EnvironmentFile=/etc/btc-rpc-explorer-regtest/btc-rpc-explorer.conf
"""

[map_variants.http_port]
mainnet = "5000"

[map_variants.root_path]
mainnet = "btc-rpc-explorer"

[config."btc-rpc-explorer.conf"]
format = "plain"
cat_dir = "conf.d"

[config."btc-rpc-explorer.conf".ivars.BTCEXP_PORT]
type = "bind_port"
default = "{http_port}"
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

[config."btc-rpc-explorer.conf".evars.bitcoin-rpc-proxy-regtest.bind_port]
name = "BTCEXP_BITCOIND_PORT"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_ADDRESS_API]
type = "string"
script = """
if [ -r "/etc/electrs-regtest/conf.d/interface.toml" ];
then
    echo electrumx
fi
"""

[config."btc-rpc-explorer.conf".hvars.BTCEXP_ELECTRUMX_SERVERS]
type = "string"
script = """
if [ -r "/etc/electrs-regtest/conf.d/interface.toml" ];
then
    echo "tcp://127.0.0.1:`grep '^ *elecctrum_rpc_addr' "/etc/electrs-regtest/conf.d/interface.toml" | sed 's/^ *elecctrum_rpc_addr *= *"[^:]*:\\([0-9]*\\)".*$/\\1/'`"
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
if [ -n "${CONFIG[\"btc-rpc-explorer-regtest/http_password\"]}" ];
then
    echo "${CONFIG[\"btc-rpc-explorer-regtest/http_password\"]}"
else
    head -c 18 /dev/urandom | base64 | tr -d '\\n'
fi
"""

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.BTCEXP_BASE_PATH]
type = "string"
default = "{root_path}"
priority = "medium"
summary = "Web prefix of web path to BTC RPC Explorer"

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf"]
format = "yaml"
with_header = true
external = true

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf".evars.btc-rpc-explorer-regtest.BTCEXP_BASE_PATH]
name = "root_path"

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf".evars.btc-rpc-explorer-regtest.BTCEXP_PORT]
name = "port"

[config."../selfhost/apps/btc-rpc-explorer-regtest.conf".hvars.rewrite]
type = "bool"
constant = "true"
