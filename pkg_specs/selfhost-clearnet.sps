name = "selfhost-clearnet"
version = "0.1.0"
summary = "Tooling for hosting web applications over clearnet domain"
extends = "selfhost"

[config."domains/clearnet.conf"]
format = "yaml"
with_header = true
cat_dir = "clearnet"

[config."domains/clearnet.conf".ivars.domain]
type = "string"
priority = "high"
summary = "The clearnet domain name used for your server"
