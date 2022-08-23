name = "ridetheln-lnd-system-@variant"
extends = "ridetheln-system"
depends_on_extended = true
depends = ["lnd-system-{variant} (>= 0.11)", "ridetheln-system (>= 0.9)"]
summary = "A bridge for integrating lnd into Ride The Lightning"

[config."nodes.d/lnd-system-{variant}"]
format = "json"
with_header = true

[extra_groups."lnd-system-{variant}"]
create = false

[config."nodes.d/lnd-system-{variant}".evars."lnd-system-@variant".rest_port]
store = false

[config."nodes.d/lnd-system-{variant}".ivars.lnNode]
type = "string"
priority = "medium"
summary = "User-friendly name of system-wide LND"
default = "Main LND"

[config."nodes.d/lnd-system-{variant}".evars."lnd-system-@variant".adminmacaroonpath]
store = false

[config."nodes.d/lnd-system-{variant}".hvars.adminmacaroondir]
type = "path"
script = "dirname \"${{CONFIG[\"lnd-system-{variant}/adminmacaroonpath\"]}}\""
structure = ["Authentication", "macaroonPath"]

[config."nodes.d/lnd-system-{variant}".hvars.index]
type = "uint"
script = "/usr/share/ridetheln/alloc_index.sh /var/lib/lnd-system-{variant}/.rtl_index /var/lib/ridetheln-system/.index_allocator"

[config."nodes.d/lnd-system-{variant}".hvars.lnImplementation]
type = "string"
constant = "LND"

[config."nodes.d/lnd-system-{variant}".hvars.server_url]
type = "string"
template = "https://127.0.0.1:{lnd-system-@variant/rest_port}"
structure = ["Settings", "lnServerUrl"]

run_as_user = "root"
register_cmd = ["bash", "-c", "echo -e '[Unit]\nAfter=lnd-system-{variant}\nRequires=lnd-system-{variant}' > /etc/systemd/system/ridetheln-system.d/bridge-lnd-system-{variant}.conf"]
unregister_cmd = ["rm", "-f", "/etc/systemd/system/ridetheln-system.d/bridge-lnd-system-{variant}.conf"]
