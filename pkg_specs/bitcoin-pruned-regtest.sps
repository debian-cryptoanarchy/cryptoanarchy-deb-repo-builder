name = "bitcoin-pruned-regtest"
extends = "bitcoin-regtest"
provides = ["bitcoin-chain-mode-regtest"]
replaces = ["bitcoin-chain-mode-regtest"]
conflicts = ["bitcoin-chain-mode-regtest"]
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
