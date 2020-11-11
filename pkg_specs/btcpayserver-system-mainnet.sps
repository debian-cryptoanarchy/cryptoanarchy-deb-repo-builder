name = "btcpayserver-system-mainnet"
bin_package = "btcpayserver"
binary = "/usr/bin/btcpayserver"
conf_param = "--conf="
user = { group = true, create = { home = true } }
conflicts = ["btcpayserver-system-selfhost-mainnet"]
# The former two of these recommends handle the situation when lnd is installed on the command line
# without explicitly selecting the network or when the selected network is regtest only, the latter
# two recommends handle the case when both networks are used.
recommends = ["selfhost (>= 0.1.5)", "selfhost (<< 0.2.0)", "btcpayserver-no-lnp-system-mainnet | lnd, btcpayserver-lnp-system-mainnet | btcpayserver-no-lnp-system-mainnet | lnd-system-regtest, btcpayserver-no-lnp-system-mainnet | btcpayserver-no-lnp-system-mainnet | lnd-system-mainnet, btcpayserver-lnp-system-mainnet | btcpayserver-no-lnp-system-mainnet"]
summary = "A cross platform, self-hosted server compatible with Bitpay API"
add_links = [ "/usr/lib/BTCPayServer/wwwroot/img/icons/icon-192x192.png /usr/share/selfhost-dashboard/apps/icons/btcpayserver-system-mainnet/entry_main.png" ]
extra_service_config = """
Restart=always
WorkingDirectory=/usr/lib/BTCPayServer
LogsDirectory=btcpayserver-system-mainnet
"""

[extra_groups.nbxplorer-mainnet-access-rpc]
create = false

[databases.pgsql]
template = """
postgres=User ID=_DBC_DBUSER_;Password=_DBC_DBPASS_;Host=_DBC_DBSERVER_;Port=_DBC_DBPORT_;Database=_DBC_DBNAME_;
"""

[config."btcpayserver.conf"]
format = "plain"
cat_dir = "conf.d"
cat_files = ["database"]

[config."btcpayserver.conf".ivars."port"]
type = "bind_port"
default = "23000"
priority = "low"
summary = "The port BTCPayServer should listen on"

[config."btcpayserver.conf".evars.nbxplorer-mainnet.port]
store = false

[config."btcpayserver.conf".evars.nbxplorer-mainnet.datadir]
store = false

[config."btcpayserver.conf".hvars."btc.explorer.url"]
type = "string"
template = "http://127.0.0.1:{nbxplorer-mainnet/port}"

[config."btcpayserver.conf".hvars."btc.explorer.cookiefile"]
type = "string"
template = "{nbxplorer-mainnet/datadir}/Main/.cookie"

[config."btcpayserver.conf".hvars."debuglog"]
type = "path"
constant = "/var/log/btcpayserver-system-mainnet/debug.log"

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.rootPath]
type = "string"
default = "/btcpay"
priority = "medium"
summary = "Web prefix of web path to BTCPayServer"

[config."../selfhost/apps/btcpayserver-system-mainnet.conf"]
format = "yaml"
with_header = true
external = true

[config."../selfhost/apps/btcpayserver-system-mainnet.conf".evars.btcpayserver-system-mainnet.rootPath]
name = "root_path"

[config."../selfhost/apps/btcpayserver-system-mainnet.conf".evars.btcpayserver-system-mainnet.port]
name = "port"
[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-mainnet/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-mainnet/meta.toml".hvars.user_friendly_name]
type = "string"
constant = "BTCPayServer"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-mainnet/meta.toml".hvars.admin_only]
type = "bool"
constant = "false"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-mainnet/meta.toml".hvars.entry_point]
type = "uint"
constant = "{ \\\"Static\\\" = { \\\"url\\\" = \\\"/Account/Login\\\" } }"


