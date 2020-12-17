name = "bitcoin-@variant"
bin_package = "bitcoind"
min_patch = "9"
binary = "/usr/share/bitcoind/bitcoind"
conf_param = "-conf="
user = { group = true, create = { home = true } }
# dpkg | bitcoin-zmq-{variant} is a hack avoiding restarts of bitcoind
depends = ["bitcoin-pruned-{variant} (>= 0.20.0-1) | bitcoin-chain-mode-{variant} (>= 1.0)", "bitcoin-pruned-{variant} (>= 0.20.0-1) | bitcoin-chain-mode-{variant} (<< 2.0)", "dpkg | bitcoin-zmq-{variant}"]
summary = "Bitcoin fully validating node"
runtime_dir = { mode = "0755" }
extra_service_config = """
# Stopping bitcoind can take a very long time
TimeoutStopSec=300
Restart=always
"""

[map_variants.insert_header]
mainnet = ""
regtest = "regtest=1\n[regtest]"

[config."bitcoin.conf"]
format = "plain"
insert_header = "{insert_header}"
cat_dir = "conf.d"
cat_files = ["chain_mode"]

[config."bitcoin.conf".ivars.fallbackfee]
# ugly hack while float doesn't exist
type = "uint"
default = "0.00001"
priority = "medium"
summary = "Fallback fee when estimation fails (recommended for {variant})"
ignore_empty = true

[config."bitcoin.conf".ivars.datadir]
type = "path"
file_type = "dir"
create = { mode = 755, owner = "$service", group = "$service" }
default = "/var/lib/bitcoin-{variant}"
priority = "medium"
summary = "Directory containing the bitcoind data"
long_doc = """
The full path to the directory which will contain timechain data (blocks and chainstate).
Important: you need around 10GB of free space!
"""

[map_variants.default_p2p_port]
mainnet = "8333"
regtest = "18444"

[map_variants.default_rpc_port]
mainnet = "8331"
regtest = "18442"

[config."bitcoin.conf".ivars.p2p_bind_port]
type = "bind_port"
default = "{default_p2p_port}"
priority = "low"
summary = "Bitcoin P2P port ({variant})"
store = false

[config."bitcoin.conf".ivars.p2p_bind_host]
type = "bind_host"
default = "0.0.0.0"
priority = "low"
summary = "Bitcoin P2P host ({variant})"
store = false

[config."bitcoin.conf".hvars.bind]
type = "string"
template = "{/p2p_bind_host}:{/p2p_bind_port}"

[config."bitcoin.conf".ivars.rpcport]
type = "bind_port"
default = "{default_rpc_port}"
priority = "low"
summary = "Bitcoin RPC port"

[config."bitcoin.conf".ivars.dbcache]
type = "uint"
default = "450"
priority = "medium"
summary = "Size of database cache in MB"

[config."bitcoin.conf".hvars.rpccookiefile]
type = "string"
template = "/var/run/bitcoin-{variant}/cookie"

[config."bitcoin.conf".postprocess]
command = ["bash", "/usr/share/bitcoind/check_needs_reindex.sh", "{variant}"]

[[config."bitcoin.conf".postprocess.generates]]
file = "/etc/bitcoin-{variant}/prev_chain_mode"
internal = true

[[config."bitcoin.conf".postprocess.generates]]
file = "/etc/bitcoin-{variant}/needs_reindex"
internal = true
