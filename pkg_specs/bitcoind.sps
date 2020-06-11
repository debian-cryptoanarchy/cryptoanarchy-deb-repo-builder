name = "bitcoind"
architecture = "any"
summary = "Bitcoin full node daemon binaries"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["bitcoin-mainnet | bitcoin-regtest"]
add_files = [
	"usr/bin/bitcoind",
	"usr/lib/libbitcoinconsensus.so",
	"usr/lib/libbitcoinconsensus.so.0",
	"usr/lib/libbitcoinconsensus.so.0.0.0",
]
add_manpages = ["share/man/man1/bitcoind.1"]
long_doc = """Bitcoin Core is the original Bitcoin client and it builds the backbone
of the network. This binary downloads and verifies the entire history
of Bitcoin transactions.

Note that this is just a binary and does nothing unless configured and
executed. Consider using bitcoin-mainnet to automatically manage the
daemon using main Bitcoin network."""
