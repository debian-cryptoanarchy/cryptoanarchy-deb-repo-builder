name = "ridetheln"
architecture = "all"
summary = "A full function web browser app for LND and C-Lightning."
depends = ["nodejs (>= 8.0.0)", "${shlibs:Depends} ${misc:Depends}"]
recommends = ["ridetheln-system", "ridetheln-lnd-system-mainnet | ridetheln-lnd-system-regtest", "ridetheln-system-selfhost"]
long_doc = """RTL is a full function, device agnostic, web user interface to help manage
lightning node operations. RTL is available on LND and C-Lightning
implementations."""
