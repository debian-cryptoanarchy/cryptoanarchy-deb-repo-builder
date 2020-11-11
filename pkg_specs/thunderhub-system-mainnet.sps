name = "thunderhub-system-mainnet"
bin_package = "thunderhub"
binary = "/usr/bin/thunderhub"
user = { group = true, create = { home = true } }
summary = "Lightning Node Manager"
depends = ["lnd-system-mainnet (>= 0.11)"]
conflicts = ["thunderhub-system-selfhost-mainnet"]
recommends = ["selfhost (>=0.1.5)", "selfhost (<<0.2.0)"]
add_links = [
	"/usr/share/thunderhub/selfhost-dashboard/entry_points/open /usr/lib/selfhost-dashboard/apps/entry_points/thunderhub-system-mainnet/open",
	"/usr/share/thunderhub/selfhost-dashboard/icons/entry_main.png /usr/share/selfhost-dashboard/apps/icons/thunderhub-system-mainnet/entry_main.png",
]
extra_service_config = """
Restart=always
EnvironmentFile=/etc/thunderhub-system-mainnet/thunderhub.conf
RuntimeDirectory=thunderhub-system-mainnet
RuntimeDirectoryMode=755
"""

[extra_groups."thunderhub-system-mainnet-sso"]
create = true

[config."thunderhub.conf"]
format = "plain"
cat_dir = "conf.d"

[config."thunderhub.conf".postprocess]
command = ["usermod", "-a", "-G", "lnd-system-mainnet", "thunderhub-system-mainnet"]

[config."thunderhub.conf".ivars.BIND_PORT]
type = "bind_port"
default = "4000"
priority = "low"
summary = "Bind port for ThunderHub"

[config."thunderhub.conf".hvars.COOKIE_PATH]
type = "path"
file_type = "regular"
constant = "/var/run/thunderhub-system-mainnet/sso/cookie"

[config."thunderhub.conf".evars.lnd-system-mainnet.grpc_port]
store = false

[config."thunderhub.conf".hvars.BITCOIN_NETWORK]
type = "string"
constant = "mainnet"

[config."thunderhub.conf".hvars.SSO_SERVER_URL]
type = "string"
template = "127.0.0.1:{lnd-system-mainnet/grpc_port}"

[config."thunderhub.conf".evars.lnd-system-mainnet.tlscertpath]
name = "SSO_CERT_PATH"

[config."thunderhub.conf".evars.lnd-system-mainnet.adminmacaroonpath]
store = false

[config."thunderhub.conf".hvars.SSO_MACAROON_PATH]
type = "path"
script = "dirname ${CONFIG[\"lnd-system-mainnet/adminmacaroonpath\"]}"

[config."thunderhub.conf".ivars.NO_CLIENT_ACCOUNTS]
type = "bool"
default = "true"
priority = "medium"
summary = "Disable client accounts? (Warning: they are messy and will be removed.)"

[config."thunderhub.conf".ivars.FETCH_PRICES]
type = "bool"
default = "false"
priority = "medium"
summary = "Should ThunderHub fetch prices from blockchain.com?"

[config."thunderhub.conf".ivars.FETCH_FEES]
type = "bool"
default = "false"
priority = "medium"
summary = "Should ThunderHub fetch fees from earn.com?"

[config."thunderhub.conf".ivars.DISABLE_LINKS]
type = "bool"
default = "true"
priority = "medium"
summary = "Disable potentially privacy-endangering links?"

[config."thunderhub.conf".ivars.NO_VERSION_CHECK]
type = "bool"
default = "true"
priority = "medium"
summary = "Disable version check? (shouldn't be needed - managed by Debian)"

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.BASE_PATH]
type = "string"
default = "/thunderhub"
priority = "medium"
summary = "Web prefix of web path to ThunderHub"

[config."../selfhost/apps/thunderhub-system-mainnet.conf"]
format = "yaml"
with_header = true
external = true

[config."../selfhost/apps/thunderhub-system-mainnet.conf".evars.thunderhub-system-mainnet.BASE_PATH]
name = "root_path"

[config."../selfhost/apps/thunderhub-system-mainnet.conf".evars.thunderhub-system-mainnet.BIND_PORT]
name = "port"

[config."../selfhost/apps/thunderhub-system-mainnet.conf".hvars.rewrite]
type = "bool"
constant = "true"

[config."../../etc/selfhost-dashboard/apps/thunderhub-system-mainnet/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/thunderhub-system-mainnet/meta.toml".hvars.user_friendly_name]
type = "string"
constant = "ThunderHub"

[config."../../etc/selfhost-dashboard/apps/thunderhub-system-mainnet/meta.toml".hvars.admin_only]
type = "bool"
constant = "true"

[config."../../etc/selfhost-dashboard/apps/thunderhub-system-mainnet/meta.toml".hvars.entry_point]
type = "string"
constant = "Dynamic"
