name = "nbxplorer-@variant"
bin_package = "nbxplorer"
binary = "/usr/bin/nbxplorer"
conf_param = "--conf="
user = { group = true, create = { home = true } }
depends = ["bitcoin-{variant} (>= 0.21.1-4)", "bitcoin-timechain-{variant}", "bitcoin-rpc-proxy (>= 0.1.1-1) | bitcoin-timechain-mainnet (= 0.1.0-9)"]
summary = "A minimalist UTXO tracker for HD Wallets."
extra_service_config = """
Restart=always
"""

[databases.pgsql]
template = """
postgres=User ID=_DBC_DBUSER_;Password=_DBC_DBPASS_;Host=_DBC_DBSERVER_;Port=_DBC_DBPORT_;Database=_DBC_DBNAME_;
"""
min_version = "13"
since = "2.4.5-1"

[map_variants.mainnet_enabled]
mainnet = "1"
regtest = "0"

[map_variants.regtest_enabled]
mainnet = "0"
regtest = "1"

[map_variants.rpc_port]
mainnet = "24445"
regtest = "24447"

[extra_groups."nbxplorer-{variant}-access-rpc"]
create = true

[migrations."<< 2.4.5-1"]
config = """
# This version started including secret information
chmod o-r /etc/nbxplorer-{variant}/nbxplorer.conf
"""

[config."nbxplorer.conf"]
format = "plain"
cat_dir = "conf.d"
cat_files = ["database"]

[config."nbxplorer.conf".hvars."network"]
type = "string"
template = "{variant}"

[config."nbxplorer.conf".hvars."automigrate"]
type = "uint"
constant = "1"

[config."nbxplorer.conf".ivars."deleteaftermigration"]
type = "bool"
default = "true"
priority = "low"
summary = "Delete old NBxplorer's database after migration"

[config."nbxplorer.conf".hvars."dbtrie"]
type = "string"
template = "0"

[config."nbxplorer.conf".ivars.datadir]
type = "path"
file_type = "dir"
default = "/var/lib/nbxplorer-{variant}"
create = { mode = 750, owner = "nbxplorer-{variant}", group = "nbxplorer-{variant}-access-rpc" }
priority = "low"
summary = "NBXplorer data directory"

[config."nbxplorer.conf".ivars."port"]
type = "bind_port"
default = "{rpc_port}"
priority = "low"
summary = "The port NBXplorer should listen on"

# Separate file to deflect possible future danger.
[config."conf.d/bitcoin_iface.conf"]
format = "plain"

[config."conf.d/bitcoin_iface.conf".hvars."btc.rpc.auth"]
type = "string"
constant = "public:public"

[config."conf.d/bitcoin_iface.conf".evars."bitcoin-@variant".p2p_bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."btc.node.endpoint"]
type = "string"
template = "127.0.0.1:{bitcoin-@variant/p2p_bind_port}"

[config."conf.d/bitcoin_iface.conf".hvars."chains"]
type = "string"
constant = "btc"

[config."conf.d/bitcoin_iface.conf".hvars."regtest"]
type = "bool"
template = "{regtest_enabled}"

[config."conf.d/bitcoin_iface.conf".hvars."mainnet"]
type = "bool"
template = "{mainnet_enabled}"

[config."conf.d/bitcoin_iface.conf".evars."bitcoin-rpc-proxy-@variant".bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."btc.rpc.url"]
type = "string"
template = "http://127.0.0.1:{bitcoin-rpc-proxy-@variant/bind_port}/"

[config."conf.d/bitcoin_iface.conf".hvars."btc.hastxindex"]
type = "bool"
script = "grep -q txindex=1 /etc/bitcoin-{variant}/chain_mode && echo true || echo false"
