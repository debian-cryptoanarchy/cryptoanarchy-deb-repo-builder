name = "lnd-system-@variant"
bin_package = "lnd"
binary = "/usr/bin/lnd"
conf_param = "-C"
user = { group = true, create = { home = true } }
depends = ["bitcoin-fullchain-{variant}", "bitcoin-timechain-{variant}"]
recommends = ["lnd-unlocker-system-{variant}"]
extended_by = ["tor-hs-patch-config", "selfhost-clearnet"]
summary = "Lightning Network Daemon"
extra_service_config = """
Restart=always
EnvironmentFile=-/var/lib/lnd-system-{variant}/.auto_unlock
"""

[map_variants.mainnet_enabled]
mainnet = "1"
regtest = "0"

[map_variants.regtest_enabled]
mainnet = "0"
regtest = "1"

[map_variants.p2p_port]
mainnet = "9735"
regtest = "9737"

[map_variants.grpc_port]
mainnet = "10009"
regtest = "10011"

[map_variants.rest_port]
mainnet = "9090"
regtest = "9092"

[migrations."<< 0.11.0-1"]
config = """
db_get lnd-system-{variant}/externalip || RET=""
if [ -z "$RET" ] || echo "$RET" | grep -E '^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]$|[0-9a-f:]*:[0-9a-f:]*:[0-9a-f:]*|\\.onion$';
then
\ttrue
else
\techo 'externalip does NOT look like an IP address or onion domain. Migrating to externalhosts' >&2
\tif db_set lnd-system-{variant}/externalhosts "$RET";
\tthen
\t\tdb_fset lnd-system-{variant}/externalhosts seen false || true
\t\tdb_set lnd-system-{variant}/externalip \"\" || true
\tfi
fi"""

[extra_groups."lnd-system-{variant}-invoice"]
create = true

[extra_groups."lnd-system-{variant}-readonly"]
create = true

[config."lnd.conf"]
format = "plain"
public = true
cat_dir = "conf.d"

[config."lnd.conf".ivars.datadir]
type = "path"
file_type = "dir"
default = "/var/lib/lnd-system-{variant}/private/data"
create = { mode = 750, owner = "$service", group = "$service"}
priority = "low"
summary = "LND data directory"

[config."lnd.conf".ivars."listen"]
type = "bind_host"
default = "0.0.0.0:{p2p_port}"
priority = "low"
summary = "The address to listen on with LN protocol"

[config."lnd.conf".ivars.adminmacaroonpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-{variant}/private/admin.macaroon"
create = { mode = 750, owner = "$service", group = "$service", only_parent = true }
priority = "low"
summary = "Admin macaroon path"

[config."lnd.conf".ivars.logdir]
type = "path"
file_type = "dir"
default = "/var/log/lnd-system-{variant}"
create = { mode = 750, owner = "$service", group = "$service"}
priority = "low"
summary = "LND log directory"

[config."lnd.conf".ivars.maxlogfiles]
type = "uint"
default = "5"
priority = "medium"
summary = "Maximum number of log files"

[config."lnd.conf".ivars.maxlogfilesize]
type = "uint"
default = "100"
priority = "medium"
summary = "Maximum size of a log file in MB"

[config."lnd.conf".ivars.invoicemacaroonpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-{variant}/invoice/invoice.macaroon"
create = { mode = 750, owner = "$service", group = "lnd-system-{variant}-invoice", only_parent = true }
priority = "low"
summary = "Invoice macaroon path"

[config."lnd.conf".ivars.readonlymacaroonpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-{variant}/readonly/readonly.macaroon"
create = { mode = 750, owner = "$service", group = "lnd-system-{variant}-readonly", only_parent = true }
priority = "low"
summary = "Readonly macaroon path"

[config."lnd.conf".ivars.tlskeypath]
type = "path"
default = "/var/lib/lnd-system-{variant}/private/tls.key"
priority = "low"
summary = "Path to key file"

[config."lnd.conf".ivars.tlscertpath]
type = "path"
file_type = "regular"
default = "/var/lib/lnd-system-{variant}/public/tls.cert"
create = { mode = 755, owner = "$service", group = "$service", only_parent = true }
priority = "low"
summary = "Path to cert file"

[config."lnd.conf".ivars.tlsextraip]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "Extra IP to add to TLS certificate"

[config."lnd.conf".ivars.tlsextradomain]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "Extra domain to add to TLS certificate"

[config."lnd.conf".ivars.externalip]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "External IP address"

[config."lnd.conf".ivars.externalhosts]
type = "bind_host"
ignore_empty = true
priority = "medium"
summary = "External host name"
store = false

# We abuse the fact that variables are not checked for uniqueness yet. :)
[config."lnd.conf".hvars.externalhosts]
type = "bind_host"
script = "if [ -z \"${{CONFIG[\"lnd-system-{variant}/externalip\"]}}\" -a -z \"${{CONFIG[\"lnd-system-{variant}/externalhosts\"]}}\" ]; then /usr/share/lnd/get_external_addr.sh {variant} \"${{CONFIG[\"lnd-system-{variant}/listen\"]}}\"; else echo -n \"${{CONFIG[\"lnd-system-{variant}/externalhosts\"]}}\"; fi"
ignore_empty = true

[config."lnd.conf".ivars.debuglevel]
# Should be enum (select)
type = "string"
default = "info"
priority = "medium"
summary = "Debug level - one of trace, debug, info, warn, error, critical"

[config."lnd.conf".ivars.alias]
type = "string"
ignore_empty = true
priority = "medium"
summary = "The funny name of your Lightning node. NOT AUTHENTICATED!"

[config."lnd.conf".ivars.color]
type = "string"
ignore_empty = true
priority = "medium"
summary = "The funny color of your Lightning node. NOT AUTHENTICATED!"

[config."lnd.conf".ivars.tlsdisableautofill]
type = "bool"
priority = "medium"
default = "true"
summary = "Disable putting private information into RPC TLS certificate of LND"

# Disabled because it needs #10 resolved in Debcrafter.
#[config."lnd.conf".ivars.nobootstrap]
#type = "bool"
#priority = "medium"
#summary = "Do not attempt to automatically seek out peers on the network."

[config."lnd.conf".ivars."bitcoin.defaultchanconfs"]
type = "uint"
default = "6"
priority = "medium"
summary = "The default number of confirmations to wait for channel to open"

[config."lnd.conf".ivars.grpc_port]
type = "bind_port"
default = "{grpc_port}"
priority = "low"
summary = "LND GRPC port"
store = false

[config."lnd.conf".ivars.grpc_bind_addr]
type = "bind_host"
default = "127.0.0.1"
priority = "medium"
summary = "LND GRPC bind address (use 0.0.0.0 to publish GRPC)"
store = false

[config."lnd.conf".hvars.rpclisten]
type = "string"
template = "{/grpc_bind_addr}:{/grpc_port}"

[config."lnd.conf".ivars.rest_port]
type = "bind_port"
default = "{rest_port}"
priority = "low"
summary = "LND REST RPC port"
store = false

[config."lnd.conf".ivars.rest_bind_addr]
type = "bind_host"
default = "127.0.0.1"
priority = "medium"
summary = "LND REST bind address (use 0.0.0.0 to publish REST)"
store = false

[config."lnd.conf".hvars.restlisten]
type = "string"
template = "{/rest_bind_addr}:{/rest_port}"

# Separate file to deflect possible future danger.
[config."conf.d/bitcoin_iface.conf"]
format = "plain"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoind.rpcuser"]
type = "string"
constant = "public"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoind.rpcpass"]
type = "string"
constant = "public"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.active"]
type = "bool"
constant = "1"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.mainnet"]
type = "bool"
template = "{mainnet_enabled}"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.regtest"]
type = "bool"
template = "{regtest_enabled}"

[config."conf.d/bitcoin_iface.conf".hvars."bitcoin.node"]
type = "string"
constant = "bitcoind"

[config."conf.d/bitcoin_iface.conf".evars."bitcoin-rpc-proxy-@variant".bind_port]
store = false

[config."conf.d/bitcoin_iface.conf".hvars."bitcoind.rpchost"]
type = "string"
template = "127.0.0.1:{bitcoin-rpc-proxy-@variant/bind_port}"

[config."conf.d/bitcoin_iface.conf".evars."bitcoin-zmq-@variant".zmqpubrawtx]
name = "bitcoind.zmqpubrawtx"

[config."conf.d/bitcoin_iface.conf".evars."bitcoin-zmq-@variant".zmqpubrawblock]
name = "bitcoind.zmqpubrawblock"
