name = "electrum-trustless-mainnet"
architecture = "all"
summary = "Electrum - Lightweight Bitcoin client (secure launcher)"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["electrum-trustless-mainnet | electrum-trustless-regtest", "python3-pyqt5"]
long_doc = """Electrum is a powerful Bitcoin wallet capable of using hardware wallets.

This package contains a launcher configured to make sure you don't leak
private data to a random Electrum server. It uses your own local server
(electrs) instead. Apart from privacy benefits, this also validates all
incoming satoshis, making it impossible to defraud you by feeding you invalid
blocks."""
