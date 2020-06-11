name = "lncli"
architecture = "any"
summary = "Lightnning Network Daemon CLI"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["lnd-system-mainnet | lnd-system-regtest"]
add_files = ["lncli /usr/lib/lncli", "xlncli /usr/share/lncli"]
long_doc = """lncli is a tool used for managing lnd from the command line. This package
also contains a wrapper used to connect to the system-wide LND by default.
You can still use --macaroonpath --rpcserver and --tlscertpath to access a
different lnd."""

[alternatives."/usr/share/lncli/xlncli"]
name = "lncli"
dest = "/usr/bin/lncli"
priority = 100

[alternatives."/usr/lib/lncli/lncli"]
name = "lncli"
dest = "/usr/bin/lncli"
priority = 50
