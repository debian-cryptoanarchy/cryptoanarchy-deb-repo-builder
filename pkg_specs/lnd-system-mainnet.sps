name = "lnd-system-mainnet"
bin_package = "lnd"
binary = "/usr/bin/lnd"
conf_param = "-C"
user = { group = true, create = { home = true } }
depends = ["bitcoin-fullchain-mainnet", "bitcoin-timechain-mainnet"]
summary = "Lightning Network Daemon"
extra_service_config = """
Restart=always
"""

[extra_groups.lnd-system-mainnet-invoice]
create = true

[extra_groups.lnd-system-mainnet-readonly]
create = true

[config."lnd.conf"]
format = "plain"
public = true
cat_dir = "conf.d"

[config."lnd.conf".ivars.datadir]
type = "path"
file_type = "dir"
default = "/var/lib/lnd-system-mainnet/private/data"
create = { mode = 750, owner = "lnd-system-mainnet", group = "lnd-system-mainnet"}
priority = "low"
summary = "LND data directory"

[config."lnd.conf".ivars."listen"]
type = "bind_host"
default = "0.0.0.0:9735"
priority = "low"
summary = "The address to listen on with LN protocol"

[config."lnd.conf".ivars.adminmacaroonpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-mainnet/private/admin.macaroon"
create = { mode = 750, owner = "lnd-system-mainnet", group = "lnd-system-mainnet", only_parent = true }
priority = "low"
summary = "Admin macaroon path"

[config."lnd.conf".ivars.logdir]
type = "path"
file_type = "dir"
default = "/var/log/lnd-system-mainnet"
create = { mode = 750, owner = "lnd-system-mainnet", group = "lnd-system-mainnet"}
priority = "low"
summary = "LND log directory"

[config."lnd.conf".ivars.maxlogfiles]
type = "uint"
default = "5"
priority = "medium"
summary = "Maximum number of log files"

[config."lnd.conf".ivars.maxlogfilesize]
type = "uint"
default = "100"
priority = "medium"
summary = "Maximum size of a log file in MB"

[config."lnd.conf".ivars.invoicemacaroonpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-mainnet/invoice/invoice.macaroon"
create = { mode = 750, owner = "lnd-system-mainnet", group = "lnd-system-mainnet-invoice", only_parent = true }
priority = "low"
summary = "Invoice macaroon path"

[config."lnd.conf".ivars.readonlymacaroonpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-mainnet/readonly/readonly.macaroon"
create = { mode = 750, owner = "lnd-system-mainnet", group = "lnd-system-mainnet-readonly", only_parent = true }
priority = "low"
summary = "Readonly macaroon path"

[config."lnd.conf".ivars.tlskeypath]
type = "path"
default = "/var/lib/lnd-system-mainnet/private/tls.key"
priority = "low"
summary = "Path to key file"

[config."lnd.conf".ivars.tlscertpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-mainnet/public/tls.cert"
create = { mode = 755, owner = "lnd-system-mainnet", group = "lnd-system-mainnet", only_parent = true }
priority = "low"
summary = "Path to cert file"

[config."lnd.conf".ivars.tlsextraip]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "Extra IP to add to TLS certificate"

[config."lnd.conf".ivars.tlsextradomain]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "Extra domain to add to TLS certificate"

[config."lnd.conf".ivars.externalip]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "External IP address"

[config."lnd.conf".ivars.debuglevel]
# Should be enum (select)
type = "string"
default = "info"
priority = "medium"
summary = "Debug level - one of trace, debug, info, warn, error, critical"

[config."lnd.conf".ivars.alias]
type = "string"
ignore_empty = true
priority = "medium"
summary = "The funny name of your Lightning node. NOT AUTHENTICATED!"

[config."lnd.conf".ivars.color]
type = "string"
ignore_empty = true
priority = "medium"
summary = "The funny color of your Lightning node. NOT AUTHENTICATED!"

# Disabled because it needs #10 resolved in Debcrafter.
#[config."lnd.conf".ivars.nobootstrap]
#type = "bool"
#priority = "medium"
#summary = "Do not attempt to automatically seek out peers on the network."

[config."lnd.conf".ivars."bitcoin.defaultchanconfs"]
type = "uint"
default = "6"
priority = "medium"
summary = "The default number of confirmations to wait for channel to open"

[config."lnd.conf".ivars.grpc_port]
type = "bind_port"
default = "10009"
priority = "low"
summary = "LND GRPC port"
store = false

[config."lnd.conf".hvars.rpclisten]
type = "string"
script = "echo \"127.0.0.1:${CONFIG[\"lnd-system-mainnet/grpc_port\"]}\""

[config."lnd.conf".ivars.rest_port]
type = "bind_port"
default = "9090"
priority = "low"
summary = "LND REST RPC port"
store = false

[config."lnd.conf".hvars.restlisten]
type = "string"
script = "echo \"127.0.0.1:${CONFIG[\"lnd-system-mainnet/rest_port\"]}\""

# Separate file to deflect possible future danger.
[config."conf.d/bitcoin_iface.conf"]
format = "plain"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoind.rpcuser"]
type = "string"
constant = "public"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoind.rpcpass"]
type = "string"
constant = "public"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.active"]
type = "bool"
constant = "1"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.mainnet"]
type = "bool"
constant = "1"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.node"]
type = "string"
constant = "bitcoind"

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-rpc-proxy-mainnet.bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."bitcoind.rpchost"]
type = "string"
script = "echo \"127.0.0.1:${CONFIG[\"bitcoin-rpc-proxy-mainnet/bind_port\"]}\""

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-zmq-mainnet.zmqpubrawtx]
name = "bitcoind.zmqpubrawtx"

[config."conf.d/bitcoin_iface.conf".evars.bitcoin-zmq-mainnet.zmqpubrawblock]
name = "bitcoind.zmqpubrawblock"
