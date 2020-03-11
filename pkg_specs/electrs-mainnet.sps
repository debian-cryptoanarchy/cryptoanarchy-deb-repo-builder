name = "electrs-mainnet"
bin_package = "electrs"
binary = "/usr/bin/electrs"
conf_param = "--conf"
conf_d = { name = "conf.d", param = "--conf-dir" }
user = { group = true, create = { home = true } }
summary = "An efficient re-implementation of Electrum Server"
depends = ["bitcoin-fullchain-mainnet"]
extra_service_config = """
Restart=always
"""

[config."conf.d/interface.toml"]
format = "toml"
public = true

[config."conf.d/interface.toml".ivars.electrum_rpc_addr]
type = "bind_host"
default = "127.0.0.1:50001"
priority = "low"
summary = "Electrum server JSONRPC 'addr:port' to listen on"

[config."conf.d/interface.toml".ivars.monitoring_addr]
type = "bind_host"
default = "127.0.0.1:4224"
priority = "low"
summary = "Prometheus monitoring 'addr:port' to listen on"

[config."conf.d/behavior.toml"]
format = "toml"
public = true

#[config."conf.d/behavior.toml".ivars.jsonrpc_import]
#type = "bool"
#default = "false"
#priority = "medium"
#summary = "Use JSONRPC instead of directly importing blk*.dat files."

[config."conf.d/credentials.conf"]
format = "toml"

[config."conf.d/credentials.conf".evars.bitcoin-mainnet.datadir]
name = "daemon_dir"

[config."conf.d/credentials.conf".evars.bitcoin-rpc-proxy-mainnet.bind_port]
store = false

[config."conf.d/credentials.conf".hvars.cookie]
type = "string"
constant = "public:public"

[config."conf.d/credentials.conf".hvars.daemon_rpc_addr]
type = "string"
script = "echo \"127.0.0.1:${CONFIG[\"bitcoin-rpc-proxy-mainnet/bind_port\"]}\""
