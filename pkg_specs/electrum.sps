name = "electrum"
architecture = "any"
summary = "Electrum - Lightweight Bitcoin client (exeutable)"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["electrum-trustless-mainnet | electrum-trustless-regtest", "python3-pyqt5"]
long_doc = """Electrum is a powerful Bitcoin wallet capable of using hardware wallets."""
