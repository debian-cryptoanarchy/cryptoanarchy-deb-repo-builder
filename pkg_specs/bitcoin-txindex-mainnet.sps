name = "bitcoin-txindex-mainnet"
extends = "bitcoin-mainnet"
provides = ["bitcoin-chain-mode-mainnet (= 1.0)", "bitcoin-fullchain-mainnet"]
replaces = ["bitcoin-chain-mode-mainnet"]
conflicts = ["bitcoin-chain-mode-mainnet"]
summary = "Activates txindex on Bitcoin full node"

[config."chain_mode"]
format = "plain"

[config."chain_mode".hvars.prune]
type = "uint"
constant = "0"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "1"
