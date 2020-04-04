name = "btcpayserver-system-selfhost-mainnet"
version = "0.1.0"
summary = "Brige for selfhosting BTCPayserver"
extends = "btcpayserver-system-mainnet"
depends = ["selfhost"]

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.rootPath]
type = "string"
default = "/btcpay"
priority = "medium"
summary = "Web prefix of web path to BTCPayServer"

[config."../selfhost/apps/btcpayserver-system-mainnet.conf"]
format = "yaml"

[config."../selfhost/apps/btcpayserver-system-mainnet.conf".evars.btcpayserver-system-selfhost-mainnet.rootPath]
name = "root_path"

[config."../selfhost/apps/btcpayserver-system-mainnet.conf".evars.btcpayserver-system-mainnet.port]
name = "port"
