name = "electrum-trustless-@variant"
architecture = "all"
summary = "Electrum - Lightweight Bitcoin client (secure launcher)"
recommends = ["electrum-trustless-{variant} | electrum-trustless-regtest", "python3-pyqt5"]
add_files = ["electrum-trustless-{variant} /usr/bin/", "electrum-trustless-{variant}.desktop /usr/share/applications/"]
long_doc = """Electrum is a powerful Bitcoin wallet capable of using hardware wallets.

This package contains a launcher configured to make sure you don't leak
private data to a random Electrum server. It uses your own local server
(electrs) instead. Apart from privacy benefits, this also validates all
incoming satoshis, making it impossible to defraud you by feeding you invalid
blocks."""
