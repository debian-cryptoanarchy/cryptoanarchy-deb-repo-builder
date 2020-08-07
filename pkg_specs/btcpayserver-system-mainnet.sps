name = "btcpayserver-system-mainnet"
bin_package = "btcpayserver"
binary = "/usr/bin/btcpayserver"
conf_param = "--conf="
user = { group = true, create = { home = true } }
# The former two of these recommends handle the situation when lnd is installed on the command line
# without explicitly selecting the network or when the selected network is regtest only, the latter
# two recommends handle the case when both networks are used.
recommends = ["btcpayserver-system-selfhost-mainnet", "btcpayserver-no-lnp-system-mainnet | lnd, btcpayserver-lnp-system-mainnet | btcpayserver-no-lnp-system-mainnet | lnd-system-regtest, btcpayserver-no-lnp-system-mainnet | btcpayserver-no-lnp-system-mainnet | lnd-system-mainnet, btcpayserver-lnp-system-mainnet | btcpayserver-no-lnp-system-mainnet"]
summary = "A cross platform, self-hosted server compatible with Bitpay API"
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
script = "echo \"http://127.0.0.1:${CONFIG[\"nbxplorer-mainnet/port\"]}/\""

[config."btcpayserver.conf".hvars."btc.explorer.cookiefile"]
type = "string"
script = "echo \"${CONFIG[\"nbxplorer-mainnet/datadir\"]}/Main/.cookie\""

[config."btcpayserver.conf".hvars."debuglog"]
type = "path"
constant = "/var/log/btcpayserver-system-mainnet/debug.log"
