name = "btcpayserver-system-regtest"
bin_package = "btcpayserver"
binary = "/usr/bin/btcpayserver"
conf_param = "--conf="
user = { group = true, create = { home = true } }
# The former two of these recommends handle the situation when lnd is installed on the command line
# without explicitly selecting the network or when the selected network is mainnet only, the latter
# two recommends handle the case when both networks are used.
recommends = ["btcpayserver-system-selfhost-regtest", "btcpayserver-no-lnp-system-regtest | lnd, btcpayserver-lnp-system-regtest | btcpayserver-no-lnp-system-regtest | lnd-system-mainnet, btcpayserver-no-lnp-system-regtest | btcpayserver-lnp-system-regtest | lnd-system-regtest, btcpayserver-lnp-system-regtest | btcpayserver-no-lnp-system-regtest"]
summary = "A cross platform, self-hosted server compatible with Bitpay API"
add_links = [ "/usr/lib/BTCPayServer/wwwroot/img/icons/icon-192x192.png /usr/share/selfhost-dashboard/apps/icons/btcpayserver-system-regtest/entry_main.png" ]
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
template = "http://127.0.0.1:{nbxplorer-regtest/port}"

[config."btcpayserver.conf".hvars."btc.explorer.cookiefile"]
type = "string"
template = "{nbxplorer-regtest/datadir}/RegTest/.cookie"

[config."btcpayserver.conf".hvars."debuglog"]
type = "path"
constant = "/var/log/btcpayserver-system-regtest/debug.log"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-regtest/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-regtest/meta.toml".hvars.user_friendly_name]
type = "string"
constant = "BTCPayServer - regtest"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-regtest/meta.toml".hvars.admin_only]
type = "bool"
constant = "false"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-regtest/meta.toml".hvars.entry_point]
type = "uint"
constant = "{ \\\"Static\\\" = { \\\"url\\\" = \\\"/Account/Login\\\" } }"
