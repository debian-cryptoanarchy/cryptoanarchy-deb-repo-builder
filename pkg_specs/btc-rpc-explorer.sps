name = "btc-rpc-explorer"
architecture = "any"
summary = "Simple, database-free Bitcoin blockchain explorer"
depends = ["nodejs (>= 8.0.0)"]
recommends = ["bitcoin-mainnet | bitcoin-regtest, btc-rpc-explorer-mainnet | bitcoin-regtest, btc-rpc-explorer-regtest | bitcoin-mainnet, btc-rpc-explorer-both | btc-rpc-explorer-mainnet | btc-rpc-explorer-regtest"]
add_files = ["/usr/lib/btc-rpc-explorer", "btc-rpc-explorer /usr/bin/", "selfhost-dashboard /usr/share/btc-rpc-explorer"]
long_doc = """This is a simple, self-hosted explorer for the Bitcoin blockchain, driven by RPC calls to your own Bitcoin node. It is easy to run and can be connected to other tools (like ElectrumX) to achieve a full-featured explorer.

Whatever reasons one may have for running a full node (trustlessness, technical curiosity, supporting the network, etc) it's helpful to appreciate the "fullness" of your node. With this explorer, you can explore not just the blockchain database, but also explore the functional capabilities of your own node."""
