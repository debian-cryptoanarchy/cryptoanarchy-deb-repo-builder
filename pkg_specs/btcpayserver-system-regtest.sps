name = "btcpayserver-system-regtest"
bin_package = "btcpayserver"
binary = "/usr/bin/btcpayserver"
conf_param = "--conf="
user = { group = true, create = { home = true } }
recommends = ["btcpayserver-system-selfhost-regtest"]
summary = "A cross platform, self-hosted server compatible with Bitpay API"
extra_service_config = """
Restart=always
WorkingDirectory=/usr/lib/BTCPayServer
LogsDirectory=btcpayserver-system-regtest
"""

[extra_groups.nbxplorer-regtest-access-rpc]
create = false

[databases.pgsql]
template = """
postgres=User ID=_DBC_DBUSER_;Password=_DBC_DBPASS_;Host=_DBC_DBSERVER_;Port=_DBC_DBPORT_;Database=_DBC_DBNAME_;
"""

[config."btcpayserver.conf"]
format = "plain"
cat_dir = "conf.d"
cat_files = ["database"]

[config."btcpayserver.conf".hvars."network"]
type = "string"
constant = "regtest"

[config."btcpayserver.conf".ivars."port"]
type = "bind_port"
default = "23002"
priority = "low"
summary = "The port BTCPayServer should listen on"

[config."btcpayserver.conf".evars.nbxplorer-regtest.port]
store = false

[config."btcpayserver.conf".evars.nbxplorer-regtest.datadir]
store = false

[config."btcpayserver.conf".hvars."btc.explorer.url"]
type = "string"
script = "echo \"http://127.0.0.1:${CONFIG[\"nbxplorer-regtest/port\"]}/\""

[config."btcpayserver.conf".hvars."btc.explorer.cookiefile"]
type = "string"
script = "echo \"${CONFIG[\"nbxplorer-regtest/datadir\"]}/Main/.cookie\""

[config."btcpayserver.conf".hvars."debuglog"]
type = "path"
constant = "/var/log/btcpayserver-system-regtest/debug.log"
