name = "nbxplorer"
architecture = "any"
summary = "A minimalist UTXO tracker for HD Wallets."
depends = ["dotnet-runtime-3.1", "aspnetcore-runtime-3.1", "${shlibs:Depends} ${misc:Depends}"]
recommends = ["nbxplorer-mainnet | nbxplorer-regtest"]
add_files = ["/usr/lib/NBXplorer", "/usr/bin/nbxplorer"]
long_doc = """The goal is to have a flexible, .NET based UTXO tracker for HD wallets. The
explorer supports P2SH,P2PKH,P2WPKH,P2WSH and Multi-sig derivation.

This explorer is not meant to be exposed on internet, but should be used as an
internal tool for tracking the UTXOs of your own service."""
