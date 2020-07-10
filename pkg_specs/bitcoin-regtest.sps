name = "bitcoin-regtest"
version = "0.18.1"
bin_package = "bitcoind"
binary = "/usr/bin/bitcoind"
conf_param = "-conf="
user = { group = true, create = { home = true } }
# dpkg | bitcoin-zmq-regtest is a hack avoiding restarts of bitcoind
depends = ["bitcoin-pruned-regtest (>= 0.20.0-1) | bitcoin-chain-mode-regtest (>= 1.0)", "bitcoin-pruned-regtest (>= 0.20.0-1) | bitcoin-chain-mode-regtest (<< 2.0)", "dpkg | bitcoin-zmq-regtest"]
summary = "Bitcoin fully validating node"
extra_service_config = """
# Stopping bitcoind can take a very long time
TimeoutStopSec=300
Restart=always
RuntimeDirectory=bitcoin-regtest
RuntimeDirectoryMode=0750
"""

[config."bitcoin.conf"]
format = "plain"
insert_header = "[regtest]"
cat_dir = "conf.d"
cat_files = ["chain_mode"]

[config."bitcoin.conf".hvars.regtest]
type = "bool"
constant = "1"

[config."bitcoin.conf".ivars.datadir]
type = "path"
file_type = "dir"
create = { mode = 755, owner = "$service", group = "$service" }
default = "/var/lib/bitcoin-regtest"
priority = { dynamic = { script = "test `df /var | tail -1 | awk '{ print $4; }'` -lt 10000000 && PRIORITY=high || PRIORITY=medium"} }
summary = "Directory containing the bitcoind data"
long_doc = """
The full path to the directory which will contain timechain data (blocks and chainstate).
Important: you need around 10GB of free space!
"""

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
