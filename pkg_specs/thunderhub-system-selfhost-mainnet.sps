name = "thunderhub-system-selfhost-mainnet"
extends = "thunderhub-system-mainnet"
replaces = false
summary = "Integration of rtl into nginx"
depends = ["selfhost (>=0.1.5)", "selfhost (<<0.2.0)"]

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

[config."../selfhost/apps/thunderhub-system-mainnet.conf".evars.thunderhub-system-selfhost-mainnet.BASE_PATH]
name = "root_path"

[config."../selfhost/apps/thunderhub-system-mainnet.conf".evars.thunderhub-system-mainnet.BIND_PORT]
name = "port"

[config."../selfhost/apps/thunderhub-system-mainnet.conf".hvars.rewrite]
type = "bool"
constant = "true"
