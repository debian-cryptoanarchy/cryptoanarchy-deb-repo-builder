name = "btcpayserver-system-selfhost-regtest"
summary = "Brige for selfhosting BTCPayserver"
extends = "btcpayserver-system-regtest"
depends = ["selfhost"]

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.rootPath]
type = "string"
default = "/btcpay-rt"
priority = "medium"
summary = "Web prefix of web path to BTCPayServer"

[config."../selfhost/apps/btcpayserver-system-regtest.conf"]
format = "yaml"
with_header = true

[config."../selfhost/apps/btcpayserver-system-regtest.conf".evars.btcpayserver-system-selfhost-regtest.rootPath]
name = "root_path"

[config."../selfhost/apps/btcpayserver-system-regtest.conf".evars.btcpayserver-system-regtest.port]
name = "port"
