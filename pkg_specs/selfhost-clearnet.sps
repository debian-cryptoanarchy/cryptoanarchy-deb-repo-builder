name = "selfhost-clearnet"
summary = "Tooling for hosting web applications over clearnet domain"
extends = "selfhost"
recommends = ["selfhost", "default-selfhost-tls (>= 1.0) | selfhost-tls (>= 1.0)", "default-selfhost-tls (<< 2.0) | selfhost-tls (<< 2.0)"]
provides = ["selfhost-domain (= 1.1)"]

[config."domains/clearnet.conf"]
format = "yaml"
with_header = true
cat_dir = "clearnet-enabled"

[config."domains/clearnet.conf".ivars.domain]
type = "string"
priority = "high"
summary = "The clearnet domain name used for your server"

[config."domains/clearnet.conf".ivars.public]
type = "bool"
priority = "medium"
summary = "Should the server be publicly accessible from outside of the device?"
default = "true"

