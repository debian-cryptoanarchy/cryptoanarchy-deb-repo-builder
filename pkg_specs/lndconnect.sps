name = "lndconnect"
architecture = "all"
summary = "A CLI helper to create lndconnect string"
depends = ["lnd-system-mainnet | lnd-system-regtest", "tor-hs-patch-config"]
add_files = ["lndconnect /usr/bin", "onion.sh /usr/share/lndconnect"]
long_doc = """lndconnect is a tool to create a string that can be used by e.g. Zap wallet
to connect to lnd. Warning: this tool is not meant to stay the same for a long time, don't rely on its API!"""

[config."lndconnect.conf"]
format = "plain"

[config."lndconnect.conf".postprocess]
command = ["/usr/share/lndconnect/onion.sh"]

[[config."lndconnect.conf".postprocess.generates]]
file = "/etc/tor/hidden-services.d/lndconnect.conf"
internal = true

[[config."lndconnect.conf".postprocess.generates]]
dir = "/var/lib/tor/lndconnect_hidden-service"
internal = true
