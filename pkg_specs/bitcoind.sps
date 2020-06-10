name = "bitcoind"
architecture = "any"
summary = "Bitcoin full node daemon binaries"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["bitcoin-mainnet | bitcoin-regtest"]
long_doc = """Bitcoin Core is the original Bitcoin client and it builds the backbone
of the network. This binary downloads and verifies the entire history
of Bitcoin transactions.

Note that this is just a binary and does nothing unless configured and
executed. Consider using bitcoin-mainnet to automatically manage the
daemon using main Bitcoin network."""
