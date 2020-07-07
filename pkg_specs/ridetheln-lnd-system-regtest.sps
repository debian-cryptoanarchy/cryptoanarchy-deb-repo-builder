name = "ridetheln-lnd-system-regtest"
extends = "ridetheln-system"
depends_on_extended = true
summary = "A bridge for integrating lnd into Ride The Lightning"

[config."nodes.d/lnd-system-regtest"]
format = "json"
with_header = true

[config."nodes.d/lnd-system-regtest".postprocess]
command = ["usermod", "-a", "-G", "lnd-system-regtest", "ridetheln-system"]

[config."nodes.d/lnd-system-regtest".evars.lnd-system-regtest.rest_port]
store = false

[config."nodes.d/lnd-system-regtest".ivars.lnNode]
type = "string"
priority = "medium"
summary = "User-friendly name of system-wide LND"
default = "Regtest LND"

[config."nodes.d/lnd-system-regtest".evars.lnd-system-regtest.adminmacaroonpath]
store = false

[config."nodes.d/lnd-system-regtest".hvars.adminmacaroondir]
type = "path"
script = "dirname \"${CONFIG[\"lnd-system-regtest/adminmacaroonpath\"]}\""
structure = ["Authentication", "macaroonPath"]

[config."nodes.d/lnd-system-regtest".hvars.index]
type = "uint"
script = "/usr/share/ridetheln/alloc_index.sh /var/lib/lnd-system-regtest/.rtl_index /var/lib/ridetheln-system/.index_allocator"

[config."nodes.d/lnd-system-regtest".hvars.lnImplementation]
type = "string"
constant = "LND"

[config."nodes.d/lnd-system-regtest".hvars.server_url]
type = "string"
script = "echo \"https://127.0.0.1:${CONFIG[\"lnd-system-regtest/rest_port\"]}/v1\""
structure = ["Settings", "lnServerUrl"]
