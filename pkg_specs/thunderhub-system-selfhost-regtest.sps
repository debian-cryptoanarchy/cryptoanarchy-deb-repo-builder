name = "thunderhub-system-selfhost-regtest"
extends = "thunderhub-system-regtest"
replaces = false
summary = "Integration of rtl into nginx"
depends = ["selfhost (>=0.1.4)", "selfhost (<<0.2.0)"]

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.BASE_PATH]
type = "string"
default = "/thunderhub-rt"
priority = "medium"
summary = "Web prefix of web path to ThunderHub"

[config."../selfhost/apps/thunderhub-system-regtest.conf"]
format = "yaml"
with_header = true

[config."../selfhost/apps/thunderhub-system-regtest.conf".evars.thunderhub-system-selfhost-regtest.BASE_PATH]
name = "root_path"

[config."../selfhost/apps/thunderhub-system-regtest.conf".evars.thunderhub-system-regtest.BIND_PORT]
name = "port"

[config."../selfhost/apps/thunderhub-system-regtest.conf".hvars.rewrite]
type = "bool"
constant = "true"
