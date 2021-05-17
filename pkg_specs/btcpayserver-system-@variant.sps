name = "btcpayserver-system-@variant"
bin_package = "btcpayserver"
binary = "/usr/bin/btcpayserver"
conf_param = "--conf="
user = { group = true, create = { home = true } }
conflicts = ["btcpayserver-system-selfhost-{variant}"]
# The former two of these recommends handle the situation when lnd is installed on the command line
# without explicitly selecting the network or when the selected network is mainnet only, the latter
# two recommends handle the case when both networks are used.
recommends = ["selfhost (>= 0.1.5)", "selfhost (<< 0.2.0)", "btcpayserver-no-lnp-system-{variant} | lnd, btcpayserver-lnp-system-{variant} | btcpayserver-no-lnp-system-{variant} | lnd-system-mainnet, btcpayserver-no-lnp-system-{variant} | btcpayserver-lnp-system-{variant} | lnd-system-{variant}, btcpayserver-lnp-system-{variant} | btcpayserver-no-lnp-system-{variant}"]
summary = "A cross platform, self-hosted server compatible with Bitpay API"
add_links = [ "/usr/lib/BTCPayServer/wwwroot/img/icons/icon-192x192.png /usr/share/selfhost-dashboard/apps/icons/btcpayserver-system-{variant}/entry_main.png" ]
extra_service_config = """
Restart=always
WorkingDirectory=/usr/lib/BTCPayServer
LogsDirectory=btcpayserver-system-{variant}
"""

[extra_groups."nbxplorer-{variant}-access-rpc"]
create = false

[databases.pgsql]
template = """
postgres=User ID=_DBC_DBUSER_;Password=_DBC_DBPASS_;Host=_DBC_DBSERVER_;Port=_DBC_DBPORT_;Database=_DBC_DBNAME_;
"""

[map_variants.http_port]
mainnet = "23000"
regtest = "23002"

[map_variants.root_path]
mainnet = "/btcpay"
regtest = "/btcpay-rt"

[map_variants.nbxplorer_network]
mainnet = "Main"
regtest = "RegTest"

[map_variants.dashboard_suffix]
mainnet = ""
regtest = " - regtest"

[config."btcpayserver.conf"]
format = "plain"
cat_dir = "conf.d"
cat_files = ["database"]

[config."btcpayserver.conf".hvars."network"]
type = "string"
template = "{variant}"

[config."btcpayserver.conf".hvars."dockerdeployment"]
type = "bool"
constant = "false"

[config."btcpayserver.conf".ivars."port"]
type = "bind_port"
default = "{http_port}"
priority = "low"
summary = "The port BTCPayServer should listen on"

[config."btcpayserver.conf".evars."nbxplorer-@variant".port]
store = false

[config."btcpayserver.conf".evars."nbxplorer-@variant".datadir]
store = false

[config."btcpayserver.conf".hvars."btc.explorer.url"]
type = "string"
template = "http://127.0.0.1:{nbxplorer-@variant/port}"

[config."btcpayserver.conf".hvars."btc.explorer.cookiefile"]
type = "string"
template = "{nbxplorer-@variant/datadir}/{nbxplorer_network}/.cookie"

[config."btcpayserver.conf".hvars."debuglog"]
type = "path"
template = "/var/log/btcpayserver-system-{variant}/debug.log"

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.rootPath]
type = "string"
default = "{root_path}"
priority = "medium"
summary = "Web prefix of web path to BTCPayServer"

[config."../selfhost/apps/btcpayserver-system-{variant}.conf"]
format = "yaml"
with_header = true
external = true

[config."../selfhost/apps/btcpayserver-system-{variant}.conf".evars."btcpayserver-system-@variant".rootPath]
name = "root_path"

[config."../selfhost/apps/btcpayserver-system-{variant}.conf".evars."btcpayserver-system-@variant".port]
name = "port"

[config."../selfhost/apps/btcpayserver-system-{variant}.conf".hvars.document_root]
type = "string"
constant = "/usr/lib/BTCPayServer/wwwroot/"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-{variant}/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-{variant}/meta.toml".hvars.user_friendly_name]
type = "string"
template = "BTCPayServer{dashboard_suffix}"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-{variant}/meta.toml".hvars.admin_only]
type = "bool"
constant = "false"

[config."../../etc/selfhost-dashboard/apps/btcpayserver-system-{variant}/meta.toml".hvars.entry_point]
type = "uint"
constant = "{ \\\"Static\\\" = { \\\"url\\\" = \\\"/Account/Login\\\" } }"
