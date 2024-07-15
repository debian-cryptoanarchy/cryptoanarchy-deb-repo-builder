name = "bitcoind"
architecture = "any"
summary = "Bitcoin full node daemon binaries"
conflicts = ["nbxplorer (<< 2.1.47)", "python3-lnpbp-testkit (<< 0.1.4)", "bitcoin-rpc-proxy-mainnet (<< 0.4.0-1)", "bitcoin-rpc-proxy-regtest (<< 0.4.0-1)"]
recommends = ["bitcoin-mainnet | bitcoin-regtest"]
suggests = ["bitcoin-cli"]
add_files = [
	"bin/bitcoind /usr/bin",
	"lib/libbitcoinconsensus.so /usr/lib",
	"lib/libbitcoinconsensus.so.0 /usr/lib",
	"lib/libbitcoinconsensus.so.0.0.0 /usr/lib",
]
import_files = [
	["../bitcoin/definitions.sh", "/usr/share/bitcoind/definitions.sh"],
	["../bitcoin/check_needs_reindex.sh", "/usr/share/bitcoind/check_needs_reindex.sh"],
	["../bitcoin/bitcoind", "/usr/share/bitcoind/bitcoind"],
	["../bitcoin/notify_startup.sh", "/usr/share/bitcoind/notify_startup.sh"]
]
add_manpages = ["share/man/man1/bitcoind.1"]
long_doc = """Bitcoin Core is the original Bitcoin client and it builds the backbone
of the network. This binary downloads and verifies the entire history
of Bitcoin transactions.

Note that this is just a binary and does nothing unless configured and
executed. Consider using bitcoin-mainnet to automatically manage the
daemon using main Bitcoin network."""
