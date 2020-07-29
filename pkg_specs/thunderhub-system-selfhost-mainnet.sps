name = "thunderhub-system-selfhost-mainnet"
extends = "thunderhub-system-mainnet"
replaces = false
summary = "Integration of rtl into nginx"
depends = ["selfhost"]

#[config."apps/thunderhub-system-mainnet.conf"]
#format = "yaml"
#with_header = true
#
#[config."conf.d/root_path.conf".ivars.root_path]
#type = "string"
#default = "/thunderhub"
#priority = "medium"
#summary = "Web prefix of web path to ThunderHub"
#
#[config."../selfhost/apps/thunderhub-system-mainnet.conf"]
#format = "plain"
#
#[config."../selfhost/apps/thunderhub-system-mainnet.conf".evars.BASE_PATH]
#name = "root_path"
#
#[config."../selfhost/apps/thunderhub-system-mainnet.conf".evars.thunderhub.BIND_PORT]
#name = "port"
