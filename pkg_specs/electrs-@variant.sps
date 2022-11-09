name = "electrs-@variant"
bin_package = "electrs"
binary = "/usr/bin/electrs"
conf_param = "--conf"
conf_d = { name = "conf.d", param = "--conf-dir" }
user = { group = true, create = { home = true } }
summary = "An efficient re-implementation of Electrum Server"
depends = ["bitcoin-fullchain-{variant}", "bitcoin-timechain-{variant}"]
extra_service_config = """
Restart=always
"""

[map_variants.network]
mainnet = "bitcoin"
regtest = "regtest"

[map_variants.default_rpc_port]
mainnet = "50001"
regtest = "60401"

[map_variants.default_prometheus_port]
mainnet = "4224"
regtest = "24224"

[migrations."<< 0.9.9-1"]
config = """
db_get electrs-{variant}/verbose || RET="2"
if [ "$RET" -eq 0 ];
then
\tlog_filters=error
elif [ "$RET" -eq 1 ];
then
\tlog_filters=warn
elif [ "$RET" -eq 2 ];
then
\tlog_filters=info
else
\tlog_filters=debug
fi
\techo "Migrating verbose level $RET to log_filters=$log_filters" >&2
\tdb_set electrs-{variant}/log_filters "$log_filters"
\tdb_fset electrs-{variant}/log_filters seen false || true
"""

[config."conf.d/interface.toml"]
format = "toml"
public = true

[config."conf.d/interface.toml".ivars.electrum_rpc_addr]
type = "bind_host"
default = "127.0.0.1:{default_rpc_port}"
priority = "low"
summary = "Electrum server JSONRPC 'addr:port' to listen on"

[config."conf.d/interface.toml".ivars.monitoring_addr]
type = "bind_host"
default = "127.0.0.1:{default_prometheus_port}"
priority = "low"
summary = "Prometheus monitoring 'addr:port' to listen on"

[config."conf.d/behavior.toml"]
format = "toml"
public = true

[config."conf.d/behavior.toml".hvars.jsonrpc_import]
type = "bool"
script = "grep -q sysperms=1 /etc/bitcoin-{variant}/bitcoin.conf && echo -n false || echo -n true"

[config."conf.d/behavior.toml".ivars.db_dir]
type = "path"
file_type = "dir"
create = { mode = 755, owner = "$service", group = "$service" }
default = "/var/lib/electrs-{variant}"
priority = "low"
summary = "Database directory of electrs ({variant})"

[config."conf.d/behavior.toml".ivars.log_filters]
type = "string"
default = "info"
priority = "medium"
summary = "Logging verbosity of electrs ({variant})"

[config."conf.d/credentials.conf"]
format = "toml"

[config."conf.d/credentials.conf".evars."bitcoin-@variant".datadir]
name = "daemon_dir"

[config."conf.d/credentials.conf".evars."bitcoin-rpc-proxy-@variant".bind_port]
store = false

[config."conf.d/credentials.conf".hvars.network]
type = "string"
template = "{network}"

[config."conf.d/credentials.conf".hvars.auth]
type = "string"
constant = "public:public"

[config."conf.d/credentials.conf".hvars.daemon_rpc_addr]
type = "string"
template = "127.0.0.1:{bitcoin-rpc-proxy-@variant/bind_port}"

[config."conf.d/credentials.conf".evars."bitcoin-@variant".p2p_bind_port]
store = false

[config."conf.d/credentials.conf".hvars."daemon_p2p_addr"]
type = "string"
template = "127.0.0.1:{bitcoin-@variant/p2p_bind_port}"
