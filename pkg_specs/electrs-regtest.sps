name = "electrs-regtest"
bin_package = "electrs"
binary = "/usr/bin/electrs"
conf_param = "--conf"
conf_d = { name = "conf.d", param = "--conf-dir" }
user = { group = true, create = { home = true } }
summary = "An efficient re-implementation of Electrum Server"
depends = ["bitcoin-fullchain-regtest", "bitcoin-timechain-regtest"]
extra_service_config = """
Restart=always
"""

[config."conf.d/interface.toml"]
format = "toml"
public = true

[config."conf.d/interface.toml".ivars.electrum_rpc_addr]
type = "bind_host"
default = "127.0.0.1:60401"
priority = "low"
summary = "Electrum server JSONRPC 'addr:port' to listen on"

[config."conf.d/interface.toml".ivars.monitoring_addr]
type = "bind_host"
default = "127.0.0.1:24224"
priority = "low"
summary = "Prometheus monitoring 'addr:port' to listen on"

[config."conf.d/behavior.toml"]
format = "toml"
public = true

[config."conf.d/behavior.toml".hvars.jsonrpc_import]
type = "bool"
script = "grep -q sysperms=1 /etc/bitcoin-regtest/bitcoin.conf && echo -n false || echo -n true"

[config."conf.d/behavior.toml".ivars.db_dir]
type = "path"
file_type = "dir"
create = { mode = 755, owner = "$service", group = "$service" }
default = "/var/lib/electrs-regtest"
priority = "low"
summary = "Database directory of electrs (regtest)"

[config."conf.d/credentials.conf"]
format = "toml"

[config."conf.d/credentials.conf".evars.bitcoin-regtest.datadir]
name = "daemon_dir"

[config."conf.d/credentials.conf".evars.bitcoin-rpc-proxy-regtest.bind_port]
store = false

[config."conf.d/credentials.conf".hvars.network]
type = "string"
constant = "regtest"

[config."conf.d/credentials.conf".hvars.cookie]
type = "string"
constant = "public:public"

[config."conf.d/credentials.conf".hvars.daemon_rpc_addr]
type = "string"
template = "127.0.0.1:{bitcoin-rpc-proxy-regtest/bind_port}"
