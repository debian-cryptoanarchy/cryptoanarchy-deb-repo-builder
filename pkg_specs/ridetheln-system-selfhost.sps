name = "ridetheln-selfhost-mainnet"
version = "0.1.0"
extends = "selfhost"
replaces = false
summary = "Integration of rtl into nginx"
depends = ["ridetheln-system"]

[config."apps/ridetheln-system.conf"]
format = "yaml"

[config."apps/ridetheln-system.conf".ivars.root_path]
type = "string"
default = "/rtl"
priority = "medium"
summary = "Web prefix of web path to Ride The Lightning"

[config."apps/ridetheln-system.conf".evars.ridetheln-system.port]
