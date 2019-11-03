name = "bitcoin-fullchain-mainnet"
version = "0.18.1"
extends = "bitcoin-mainnet"
replaces = true
summary = "Bitcoin fully validating node"

[config."chain_mode"]
internal = true
content = """
prune=0
txindex=0
"""
