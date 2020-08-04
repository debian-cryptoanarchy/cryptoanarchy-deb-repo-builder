name = "thunderhub"
# it compiles libsecp256k1 TODO: use system one
architecture = "any"
summary = "Lightning Node Manager"
depends = ["nodejs (>= 8.0.0)", "${shlibs:Depends} ${misc:Depends}"]
recommends = ["bitcoin-mainnet | bitcoin-regtest, thunderhub-system-mainnet | bitcoin-regtest, thunderhub-system-regtest | bitcoin-mainnet, thunderhub-system-both | thunderhub-system-mainnet | thunderhub-system-regtest"]
add_files = ["/usr/lib/thunderhub", "/usr/bin/thunderhub", "thunderhub-open /usr/bin/"]
long_doc = """ThunderHub is an open-source LND node manager where you can manage and monitor your node on any device or browser. It allows you to take control of the lightning network with a simple and intuitive UX and the most up-to-date tech stack."""
