name = "btc-rpc-explorer-@variant"
bin_package = "btc-rpc-explorer"
binary = "/usr/bin/btc-rpc-explorer"
user = { group = true, create = { home = true } }
summary = "Simple, database-free Bitcoin blockchain explorer ({variant})"
depends = ["bitcoin-timechain-{variant} (>= 0.1.0-5)"]
suggests = ["electrs-{variant} | bitcoin-txindex-{variant}"]
conflicts = ["btc-rpc-explorer-selfhost-{variant}"]
recommends = ["selfhost (>=0.1.5)", "selfhost (<<0.2.0)"]
extended_by = ["electrs-{variant}"]
add_links = [ "/usr/lib/btc-rpc-explorer/public/img/logo/logo-{variant}.png /usr/share/selfhost-dashboard/apps/icons/btc-rpc-explorer-{variant}/entry_main.png", "/usr/lib/btc-rpc-explorer/selfhost-dashboard/entry_points/open /usr/lib/selfhost-dashboard/apps/entry_points/btc-rpc-explorer-{variant}/open" ]
runtime_dir = { mode = "755" }
extra_triggers = ["selfhost-dashboard"]
extra_service_config = """
Restart=always
EnvironmentFile=/etc/btc-rpc-explorer-{variant}/btc-rpc-explorer.conf
"""

[map_variants.http_port]
mainnet = "5000"
regtest = "5002"

[map_variants.root_path]
mainnet = "/btc-explorer"
regtest = "/btc-explorer-rt"

[config."btc-rpc-explorer.conf"]
format = "plain"
cat_dir = "conf.d"

[config."btc-rpc-explorer.conf".ivars.BTCEXP_PORT]
type = "bind_port"
default = "{http_port}"
priority = "low"
summary = "Bind port for BTC RPC Explorer"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BITCOIND_USER]
type = "string"
constant = "public"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BITCOIND_PASS]
type = "string"
constant = "public"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_BITCOIND_HOST]
type = "string"
constant = "127.0.0.1"

[config."btc-rpc-explorer.conf".evars."bitcoin-rpc-proxy-@variant".bind_port]
name = "BTCEXP_BITCOIND_PORT"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_ADDRESS_API]
type = "string"
script = """
if [ -r "/etc/electrs-{variant}/conf.d/interface.toml" ];
then
    echo electrumx
fi
"""

[config."btc-rpc-explorer.conf".hvars.BTCEXP_ELECTRUMX_SERVERS]
type = "string"
script = """
if [ -r "/etc/electrs-{variant}/conf.d/interface.toml" ];
then
    echo "tcp://127.0.0.1:`grep '^ *electrum_rpc_addr' "/etc/electrs-{variant}/conf.d/interface.toml" | sed 's/^ *electrum_rpc_addr *= *"[^:]*:\\([0-9]*\\)".*$/\\1/'`"
fi
"""
ignore_empty = true

[config."btc-rpc-explorer.conf".ivars.BTCEXP_PRIVACY_MODE]
type = "bool"
default = "true"
priority = "medium"
summary = "Enable privacy mode of BTC RPC Explorer? (No exchange rates)"

[config."btc-rpc-explorer.conf".ivars.http_password]
type = "string"
default = ""
priority = "medium"
summary = "HTTP password for BTC RPC Explorer (empty = generate random)"
store = false

# We need to do it like this instead of directly because of backcompat
[config."btc-rpc-explorer.conf".hvars.BTCEXP_BASIC_AUTH_PASSWORD]
type = "string"
ignore_empty = true
template = "{/http_password}"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_SSO_TOKEN_FILE]
type = "path"
file_type = "regular"
template = "/var/run/btc-rpc-explorer-{variant}/sso/cookie"

[config."btc-rpc-explorer.conf".hvars.BTCEXP_SSO_LOGIN_REDIRECT_URL]
type = "string"
ignore_empty = true
script = "grep -q '^root_path: ' /etc/selfhost/apps/selfhost-dashboard.conf | sed 's/^root_path: \"\\(.*\\)\"$/\\1/'"

[config."conf.d/root_path.conf"]
format = "plain"

[config."conf.d/root_path.conf".ivars.BTCEXP_BASEURL]
type = "string"
default = "{root_path}"
priority = "medium"
summary = "Web prefix of web path to BTC RPC Explorer"

[config."../selfhost/apps/btc-rpc-explorer-{variant}.conf"]
format = "yaml"
with_header = true
external = true

[config."../selfhost/apps/btc-rpc-explorer-{variant}.conf".evars."btc-rpc-explorer-@variant".BTCEXP_BASEURL]
name = "root_path"

[config."../selfhost/apps/btc-rpc-explorer-{variant}.conf".evars."btc-rpc-explorer-@variant".BTCEXP_PORT]
name = "port"

[config."../selfhost/apps/btc-rpc-explorer-{variant}.conf".hvars.rewrite]
type = "bool"
constant = "false"

[config."../selfhost/apps/btc-rpc-explorer-{variant}.conf".hvars.document_root]
type = "string"
constant = "/usr/lib/btc-rpc-explorer/public/"

[config."../../etc/selfhost-dashboard/apps/btc-rpc-explorer-{variant}/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/btc-rpc-explorer-{variant}/meta.toml".hvars.user_friendly_name]
type = "string"
constant = "BTC Explorer"

[config."../../etc/selfhost-dashboard/apps/btc-rpc-explorer-{variant}/meta.toml".hvars.admin_only]
type = "bool"
constant = "true"

[config."../../etc/selfhost-dashboard/apps/btc-rpc-explorer-{variant}/meta.toml".hvars.entry_point]
type = "string"
constant = "Dynamic"
