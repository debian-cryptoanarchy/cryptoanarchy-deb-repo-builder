name = "thunderhub-system-mainnet"
bin_package = "thunderhub"
binary = "/usr/bin/thunderhub"
user = { group = true, create = { home = true } }
summary = "Lightning Node Manager"
depends = ["thunderhub (>= 0.9.2)"]
recommends = ["thunderhub-system-selfhost-mainnet"]
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
script = "echo \"127.0.0.1:${CONFIG[\"lnd-system-mainnet/grpc_port\"]}\""

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
