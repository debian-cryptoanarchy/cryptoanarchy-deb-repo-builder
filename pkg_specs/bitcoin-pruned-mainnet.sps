name = "bitcoin-pruned-mainnet"
extends = "bitcoin-mainnet"
provides = ["bitcoin-chain-mode-mainnet (= 1.0)"]
replaces = ["bitcoin-chain-mode-mainnet"]
conflicts = ["bitcoin-chain-mode-mainnet"]
summary = "Bitcoin fully validating node without pruning"

[config."chain_mode"]
format = "plain"

[config."chain_mode".ivars.prune]
type = "uint"
default = "550"
priority = "medium"
summary = "How much of the Bitcoin block data to keep? (in MiB, >= 550)"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "0"
