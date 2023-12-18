name = "btc-transmuter-system-@variant"
bin_package = "btc-transmuter"
binary = "/usr/bin/btc-transmuter"
conf_param = "--conf="
user = { group = true, create = { home = true } }
recommends = ["selfhost (>= 0.1.5)", "selfhost (<< 0.2.0)"]
summary = "A self-hosted ,modular IFTTT-inspired system for bitcoin services written in C# - service package"
add_links = [ "/usr/lib/BtcTransmuter/wwwroot/assets/logo.png /usr/share/selfhost-dashboard/apps/icons/btc-transmuter-system-{variant}/entry_main.png" ]
extra_service_config = """
Restart=always
EnvironmentFile=/etc/btc-transmuter-system-{variant}/btc-transmuter.conf
WorkingDirectory=/usr/lib/BtcTransmuter
LogsDirectory=btc-transmuter-system-{variant}
"""

[extra_groups."nbxplorer-{variant}-access-rpc"]
create = false

[databases.pgsql]
template = """
TRANSMUTER_Database=User ID=_DBC_DBUSER_;Password=_DBC_DBPASS_;Host=_DBC_DBSERVER_;Port=_DBC_DBPORT_;Database=_DBC_DBNAME_;
"""

[map_variants.http_port]
mainnet = "33000"
regtest = "33002"

[map_variants.root_path]
mainnet = "/transmuter"
regtest = "/transmuter-rt"

[map_variants.nbxplorer_network]
mainnet = "Main"
regtest = "RegTest"

[config."btc-transmuter.conf"]
format = "plain"
cat_dir = "conf.d"
cat_files = ["database"]

[config."btc-transmuter.conf".hvars."TRANSMUTER_DatabaseType"]
type = "string"
constant = "postgres"

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.listen_port]
type = "bind_port"
default = "{http_port}"
priority = "low"
summary = "Port for BtcTransmuter {variant} to listen on"
store = false

[config."btc-transmuter.conf".hvars."ASPNETCORE_URLS"]
type = "string"
template = "http://127.0.0.1:{/listen_port}"

[config."btc-transmuter.conf".hvars."TRANSMUTER_DataProtectionDir"]
type = "string"
template = "/var/lib/btc-transmuter-system-{variant}/keys"

[config."btc-transmuter.conf".hvars."TRANSMUTER_DataProtectionApplicationName"]
type = "string"
template = "btc-transmuter"

[config."btc-transmuter.conf".hvars."TRANSMUTER_ExtensionsDir"]
type = "string"
template = "/var/lib/btc-transmuter-system-{variant}/extensions"

[config."btc-transmuter.conf".evars."nbxplorer-@variant"."port"]
store = false

[config."btc-transmuter.conf".hvars."NBXplorer_Uri"]
type = "string"
template = "http://127.0.0.1:{nbxplorer-@variant/port}"

[config."btc-transmuter.conf".hvars."NBXplorer_Cryptos"]
type = "string"
constant = "btc"

[config."btc-transmuter.conf".hvars."NBXplorer_NetworkType"]
type = "string"
template = "{variant}"

[config."btc-transmuter.conf".evars."nbxplorer-@variant".datadir]
store = false

[config."btc-transmuter.conf".hvars."NBXplorer_CookieFile"]
type = "string"
template = "{nbxplorer-@variant/datadir}/{nbxplorer_network}/.cookie"

[config."conf.d/root_path.conf".ivars.TRANSMUTER_ROOTPATH]
type = "string"
default = "{root_path}"
priority = "medium"
summary = "Web prefix of web path to BtcTransmuter"

[config."../selfhost/apps/btc-transmuter-system-{variant}.conf"]
format = "yaml"
with_header = true
external = true

[config."../selfhost/apps/btc-transmuter-system-{variant}.conf".evars."btc-transmuter-system-@variant".TRANSMUTER_ROOTPATH]
name = "root_path"

[config."../selfhost/apps/btc-transmuter-system-{variant}.conf".evars."btc-transmuter-system-@variant".listen_port]
name = "port"

[config."../../etc/selfhost-dashboard/apps/btc-transmuter-system-{variant}/meta.toml"]
format = "toml"
external = true

[config."../selfhost/apps/btc-transmuter-system-{variant}.conf".hvars.document_root]
type = "string"
constant = "/usr/lib/BtcTransmuter/wwwroot/"

[config."../../etc/selfhost-dashboard/apps/btc-transmuter-system-{variant}/meta.toml".hvars.user_friendly_name]
type = "string"
constant = "BTC Transmuter"

[config."../../etc/selfhost-dashboard/apps/btc-transmuter-system-{variant}/meta.toml".hvars.admin_only]
type = "bool"
constant = "false"

[config."../../etc/selfhost-dashboard/apps/btc-transmuter-system-{variant}/meta.toml".hvars.entry_point]
type = "uint"
constant = "{ \\\"Static\\\" = { \\\"url\\\" = \\\"/\\\" } }"
