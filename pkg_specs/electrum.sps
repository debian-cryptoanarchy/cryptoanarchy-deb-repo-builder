name = "electrum"
architecture = "any"
summary = "Electrum - Lightweight Bitcoin client (exeutable)"
recommends = ["electrum-trustless-mainnet | electrum-trustless-regtest", "python3-pyqt5"]
add_files = ["electrum /usr/bin", "electrum-trustless-launcher /usr/share/electrum"]
long_doc = """Electrum is a powerful Bitcoin wallet capable of using hardware wallets."""
