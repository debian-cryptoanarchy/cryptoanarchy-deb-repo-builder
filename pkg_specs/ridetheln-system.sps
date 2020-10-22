name = "ridetheln-system"
bin_package = "ridetheln"
binary = "/usr/bin/ridetheln"
user = { group = true, create = { home = true } }
summary = "A full function web browser app for LND and C-Lightning - service package"
depends = ["ridetheln (>= 0.9)", "jq"]
recommends = ["ridetheln-system-selfhost", "bitcoin-mainnet | bitcoin-regtest, ridetheln-lnd-system-mainnet | bitcoin-regtest, ridetheln-lnd-system-regtest | bitcoin-mainnet, ridetheln-lnd-system-both | ridetheln-lnd-system-mainnet | ridetheln-lnd-system-regtest"]
add_links = [
	"/usr/share/ridetheln/selfhost-dashboard/entry_points/open /usr/lib/selfhost-dashboard/apps/entry_points/ridetheln-system/open",
	"/usr/lib/ridetheln/angular/assets/images/favicon-dark/android-chrome-192x192.png /usr/share/selfhost-dashboard/apps/icons/ridetheln-system/entry_main.png",
]
extra_service_config = """
Restart=always
Environment=RTL_CONFIG_PATH=/var/lib/ridetheln-system
"""

[extra_groups."ridetheln-system-sso"]
create = true

[config."rtl.conf"]
format = "json"
with_header = true

[config."rtl.conf".postprocess]
command = ["bash", "/usr/share/ridetheln/update_config.sh"]

[config."rtl.conf".ivars.port]
type = "bind_port"
default = "3000"
priority = "low"
summary = "Bind port for Ride The Lightning HTTP"

[config."rtl.conf".hvars.SSO_enabled]
type = "uint"
constant = "1"
structure = ["SSO", "rtlSSO"]

[config."rtl.conf".hvars.SSO_cookie_path]
type = "path"
file_type = "regular"
create = { mode = 750, owner = "$service", group = "$service", only_parent = true }
constant = "/var/lib/ridetheln-system/sso/cookie"
structure = ["SSO", "rtlCookiePath"]

[config."rtl.conf".fvars.nodes]
type = "dir"
repr = "array"
path = "nodes.d"

[config."../../etc/selfhost-dashboard/apps/ridetheln-system/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/ridetheln-system/meta.toml".hvars.user_friendly_name]
type = "string"
constant = "Ride The Lightning"

[config."../../etc/selfhost-dashboard/apps/ridetheln-system/meta.toml".hvars.admin_only]
type = "bool"
constant = "true"

[config."../../etc/selfhost-dashboard/apps/ridetheln-system/meta.toml".hvars.entry_point]
type = "string"
constant = "Dynamic"
