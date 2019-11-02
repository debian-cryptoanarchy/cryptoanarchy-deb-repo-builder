name = "bitcoin-txindex-mainnet"
version = "0.1"
extends = "bitcoin-mainnet"
replaces = true
summary = "Activates txindex on Bitcoin full node"

[config."chain_mode"]
content = """
prune=0
txindex=1
"""
