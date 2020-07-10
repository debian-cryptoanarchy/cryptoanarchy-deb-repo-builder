name = "bitcoin-fullchain-mainnet"
extends = "bitcoin-mainnet"
provides = ["bitcoin-chain-mode-mainnet (= 1.0)"]
replaces = ["bitcoin-chain-mode-mainnet"]
conflicts = ["bitcoin-chain-mode-mainnet"]
summary = "Bitcoin fully validating node"

[config."chain_mode"]
format = "plain"

[config."chain_mode".hvars.prune]
type = "uint"
constant = "0"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "0"
