name = "bitcoin-regtest"
bin_package = "bitcoind"
binary = "/usr/bin/bitcoind"
conf_param = "-conf="
user = { group = true, create = { home = true } }
# dpkg | bitcoin-zmq-regtest is a hack avoiding restarts of bitcoind
depends = ["bitcoin-pruned-regtest (>= 0.20.0-1) | bitcoin-chain-mode-regtest (>= 1.0)", "bitcoin-pruned-regtest (>= 0.20.0-1) | bitcoin-chain-mode-regtest (<< 2.0)", "dpkg | bitcoin-zmq-regtest"]
summary = "Bitcoin fully validating node"
runtime_dir = { mode = "0750" }
extra_service_config = """
# Stopping bitcoind can take a very long time
TimeoutStopSec=300
Restart=always
"""

[config."bitcoin.conf"]
format = "plain"
insert_header = "regtest=1\n[regtest]"
cat_dir = "conf.d"
cat_files = ["chain_mode"]

[config."bitcoin.conf".ivars.fallbackfee]
# ugly hack while float doesn't exist
type = "uint"
default = "0.00001"
priority = "medium"
summary = "Fallback fee when estimation fails (recommended for regtest)"
ignore_empty = true

[config."bitcoin.conf".ivars.datadir]
type = "path"
file_type = "dir"
create = { mode = 755, owner = "$service", group = "$service" }
default = "/var/lib/bitcoin-regtest"
priority = "medium"
summary = "Directory containing the bitcoind data"
long_doc = """
The full path to the directory which will contain timechain data (blocks and chainstate).
Important: you need around 10GB of free space!
"""

[config."bitcoin.conf".ivars.p2p_bind_port]
type = "bind_port"
default = "18444"
priority = "low"
summary = "Bitcoin P2P port (regtest)"
store = false

[config."bitcoin.conf".ivars.p2p_bind_host]
type = "bind_host"
default = "0.0.0.0"
priority = "low"
summary = "Bitcoin P2P port (regtest)"
store = false

[config."bitcoin.conf".hvars.bind]
type = "string"
template = "{/p2p_bind_host}:{/p2p_bind_port}"

[config."bitcoin.conf".ivars.rpcport]
type = "bind_port"
default = "18442"
priority = "low"
summary = "Bitcoin RPC port"

[config."bitcoin.conf".ivars.dbcache]
type = "uint"
default = "450"
priority = "medium"
summary = "Size of database cache in MB"

[config."bitcoin.conf".hvars.rpccookiefile]
type = "string"
constant = "/var/run/bitcoin-regtest/cookie"
