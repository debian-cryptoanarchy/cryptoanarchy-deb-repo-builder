name = "thunderhub"
# it compiles libsecp256k1 TODO: use system one
architecture = "any"
summary = "Lightning Node Manager"
depends = ["nodejs (>= 8.0.0)"]
recommends = ["bitcoin-mainnet | bitcoin-regtest, thunderhub-system-mainnet | bitcoin-regtest, thunderhub-system-regtest | bitcoin-mainnet, thunderhub-system-both | thunderhub-system-mainnet | thunderhub-system-regtest"]
# Interestingly, this is not needed because *our* interface consists of scripts that are in the main package and those where (had to be) updated.
#conflicts = ["thunderhub-system-mainnet (<< 0.11.0)", "thunderhub-system-regtest (<< 0.11.0)"]
add_files = ["/usr/lib/thunderhub", "thunderhub /usr/bin/", "thunderhub-open /usr/bin/", "selfhost-dashboard /usr/share/thunderhub"]
long_doc = """ThunderHub is an open-source LND node manager where you can manage and monitor your node on any device or browser. It allows you to take control of the lightning network with a simple and intuitive UX and the most up-to-date tech stack."""
