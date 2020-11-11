name = "ridetheln-lnd-system-mainnet"
extends = "ridetheln-system"
depends_on_extended = true
depends = ["lnd-system-mainnet (>= 0.11)", "ridetheln-system (>= 0.9)"]
summary = "A bridge for integrating lnd into Ride The Lightning"

[config."nodes.d/lnd-system-mainnet"]
format = "json"
with_header = true

[config."nodes.d/lnd-system-mainnet".postprocess]
command = ["usermod", "-a", "-G", "lnd-system-mainnet", "ridetheln-system"]

[config."nodes.d/lnd-system-mainnet".evars.lnd-system-mainnet.rest_port]
store = false

[config."nodes.d/lnd-system-mainnet".ivars.lnNode]
type = "string"
priority = "medium"
summary = "User-friendly name of system-wide LND"
default = "Main LND"

[config."nodes.d/lnd-system-mainnet".evars.lnd-system-mainnet.adminmacaroonpath]
store = false

[config."nodes.d/lnd-system-mainnet".hvars.adminmacaroondir]
type = "path"
script = "dirname \"${CONFIG[\"lnd-system-mainnet/adminmacaroonpath\"]}\""
structure = ["Authentication", "macaroonPath"]

[config."nodes.d/lnd-system-mainnet".hvars.index]
type = "uint"
script = "/usr/share/ridetheln/alloc_index.sh /var/lib/lnd-system-mainnet/.rtl_index /var/lib/ridetheln-system/.index_allocator"

[config."nodes.d/lnd-system-mainnet".hvars.lnImplementation]
type = "string"
constant = "LND"

[config."nodes.d/lnd-system-mainnet".hvars.server_url]
type = "string"
template = "https://127.0.0.1:{lnd-system-mainnet/rest_port}"
structure = ["Settings", "lnServerUrl"]
