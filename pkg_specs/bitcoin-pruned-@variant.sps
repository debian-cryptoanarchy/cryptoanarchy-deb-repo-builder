name = "bitcoin-pruned-@variant"
extends = "bitcoin-@variant"
provides = ["bitcoin-chain-mode-{variant} (= 1.0)"]
replaces = ["bitcoin-chain-mode-{variant}"]
conflicts = ["bitcoin-chain-mode-{variant}"]
summary = "Bitcoin fully validating node without pruning"

[config."chain_mode"]
format = "plain"

[config."chain_mode".ivars.prune]
type = "uint"
default = "550"
priority = "medium"
summary = "How much of the {variant} Bitcoin block data to keep? (in MiB, >= 550)"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "0"
