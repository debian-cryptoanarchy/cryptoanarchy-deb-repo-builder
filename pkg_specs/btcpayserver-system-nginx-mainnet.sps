name = "btcpayserver-system-nginx-mainnet"
version = "0.1.0"
extends = "btcpayserver-system-mainnet"
replaces = false
summary = "Integration of btcpayserver into nginx"
depends = ["nginx", "ruby-mustache", "bash"]

[config."btcpayserver-system-nginx-mainnet.conf"]
format = "yaml"
# Mainly useful for TLS/Tor
cat_dir = "btcpayserver-system-nginx-mainnet.conf.d"
postprocess = ["bash", "/usr/share/btcpayserver-system-nginx-mainnet/generate_config.sh"]

[config."btcpayserver-system-nginx-mainnet.conf".ivars.btcpayserver_domain]
type = "string"
priority = "high"
summary = "The domain name used for your BTCPay Server"

[config."btcpayserver-system-nginx-mainnet.conf".evars.btcpayserver-system-mainnet.rootPath]
name = "btcpay_root_path"

[config."btcpayserver-system-nginx-mainnet.conf".evars.btcpayserver-system-mainnet.port]
name = "btcpay_port"
