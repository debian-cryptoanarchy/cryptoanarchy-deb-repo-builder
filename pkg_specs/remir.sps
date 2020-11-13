name = "remir"
summary = "A simple server for controlling IR-enabled devices. (service package)"
bin_package = "python3-remir"
binary = "/usr/bin/remir"
conf_param = "--conf"
user = { group = true, create = { home = false } }
recommends = ["selfhost (>= 0.1.5)", "selfhost (<< 0.2.0)"]
extra_triggers = ["/etc/lirc/lircd.conf.d"]
runtime_dir = { mode = "750" }
extra_service_config = """
Restart=always
"""

[config."remir.toml"]
format = "toml"

[config."remir.toml".ivars.password]
type = "string"
default = ""
priority = "high"
summary = "Password to access remir (empty generates random)"
ignore_empty = true

[config."remir.toml".ivars.port]
type = "bind_port"
default = "8123"
priority = "medium"
summary = "Port for remir to listen on"

[config."remir.toml".ivars.bind_address]
type = "bind_host"
default = "127.0.0.1"
priority = "medium"
summary = "Address for remir to listen on"
ignore_empty = true

[config."../selfhost/apps/remir.conf"]
format = "yaml"
external = true
with_header = true

[config."../selfhost/apps/remir.conf".ivars.root_path]
type = "string"
default = "/remir"
priority = "medium"
summary = "Web prefix of web path to remir"

[config."../selfhost/apps/remir.conf".evars.remir.port]
name = "port"

[config."../selfhost/apps/remir.conf".hvars.rewrite]
type = "bool"
constant = "true"
