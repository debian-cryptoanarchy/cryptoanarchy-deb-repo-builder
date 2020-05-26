name = "selfhost-clearnet-certbot"
version = "0.1.0"
extends = "selfhost"
replaces = false
depends = ["certbot", "python3-certbot-nginx", "bash"]
provides = ["default-selfhost-tls (= 1.0)", "selfhost-tls (= 1.0)"]
summary = "Integration of certbot into selfhost/nginx"

[config."clearnet-wip/tls.conf"]
format = "yaml"

[config."clearnet-wip/tls.conf".ivars.hsts]
type = "bool"
priority = "medium"
summary = "Should strict transport security be enabled?"
default = "true"

[config."clearnet-wip/tls.conf".ivars.hsts_max_age]
type = "uint"
priority = "medium"
summary = "The number of seconds strict transport security is valid for"
default = "31536000"

[config."clearnet-wip/tls.conf".evars.selfhost-clearnet.domain]
store = false

[config."clearnet-wip/tls.conf".hvars.tls_key]
type = "path"
file_type = "regular"
script = "echo \"/etc/selfhost/tls/${CONFIG[\"selfhost-clearnet/domain\"]}.key\""
create = { mode = 750, owner = "root", group = "root", only_parent = true }

[config."clearnet-wip/tls.conf".hvars.tls_cert]
type = "path"
file_type = "regular"
script = "echo \"/etc/selfhost/tls/${CONFIG[\"selfhost-clearnet/domain\"]}.fullchain\""
create = { mode = 750, owner = "root", group = "root", only_parent = true }

# Inactive due to unresolved issue: https://github.com/certbot/certbot/issues/7584
#[config."clearnet-wip/tls.conf".hvars.tls_include]
#type = "path"
#constant = "/etc/letsencrypt/options-ssl-nginx.conf"

[config."clearnet-certbot.conf"]
format = "plain"

[config."clearnet-certbot.conf".postprocess]
command = ["bash", "/usr/share/selfhost-clearnet-certbot/generate_certs.sh"]

[[config."clearnet-certbot.conf".postprocess.generates]]
dir = "tls"
internal = true

[[config."clearnet-certbot.conf".postprocess.generates]]
dir = "/var/lib/selfhost-clearnet-certbot/webroot"
internal = true

[config."clearnet-certbot.conf".evars.selfhost-clearnet.domain]

[config."clearnet-certbot.conf".ivars.email]
type = "string"
priority = "high"
summary = "An e-mail address to use for letsencrypt registration and security notifications."

[config."clearnet-certbot.conf".ivars.eff_email]
type = "bool"
default = "false"
priority = "medium"
summary = "Should your e-mail address be shared with Electronic Frontier Foundation?"
