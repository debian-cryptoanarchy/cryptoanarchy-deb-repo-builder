name = "btcpayserver-system-nginx-certbot-mainnet"
version = "0.1.0"
extends = "btcpayserver-system-mainnet"
replaces = false
depends = ["btcpayserver-system-nginx-mainnet", "certbot", "bash"]
summary = "Integration of certbot into btcpayserver/nginx"

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf"]
format = "yaml"

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".ivars.public]
type = "bool"
priority = "medium"
summary = "Should the server be publicly accessible from outside of the device?"
default = "true"

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".ivars.hsts]
type = "bool"
priority = "medium"
summary = "Should strict transport security be enabled?"
default = "true"

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".ivars.hsts_max_age]
type = "uint"
priority = "medium"
summary = "The number of seconds strict transport security is valid for"
default = "31536000"

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".evars.btcpayserver-system-nginx-mainnet.btcpayserver_domain]
store = false

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".hvars.tls_key]
type = "path"
file_type = "regular"
script = "echo \"/etc/btcpayserver-system-mainnet/tls/${CONFIG[\"btcpayserver-system-nginx-mainnet/btcpayserver_domain\"]}.key\""
create = { mode = 750, owner = "root", group = "root", only_parent = true }

[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".hvars.tls_cert]
type = "path"
file_type = "regular"
script = "echo \"/etc/btcpayserver-system-mainnet/tls/${CONFIG[\"btcpayserver-system-nginx-mainnet/btcpayserver_domain\"]}.fullchain\""
create = { mode = 750, owner = "root", group = "root", only_parent = true }

# Inactive due to unresolved issue: https://github.com/certbot/certbot/issues/7584
#[config."btcpayserver-system-nginx-mainnet.conf.d/certbot.conf".hvars.tls_include]
#type = "path"
#constant = "/etc/letsencrypt/options-ssl-nginx.conf"

[config."btcpayserver-system-nginx-certbot-mainnet.conf"]
format = "plain"
postprocess = ["bash", "/usr/share/btcpayserver-system-nginx-certbot-mainnet/generate_certs.sh"]

[config."btcpayserver-system-nginx-certbot-mainnet.conf".evars.btcpayserver-system-nginx-mainnet.btcpayserver_domain]

[config."btcpayserver-system-nginx-certbot-mainnet.conf".ivars.email]
type = "string"
priority = "high"
summary = "An e-mail address to use for letsencrypt registration and security notifications."

[config."btcpayserver-system-nginx-certbot-mainnet.conf".ivars.eff_email]
type = "bool"
default = "false"
priority = "medium"
summary = "Should your e-mail address be shared with Electronic Frontier Foundation?"
