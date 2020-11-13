name = "bitcoin-fullchain-@variant"
extends = "bitcoin-@variant"
provides = ["bitcoin-chain-mode-{variant} (= 1.0)"]
replaces = ["bitcoin-chain-mode-{variant}"]
conflicts = ["bitcoin-chain-mode-{variant}"]
summary = "Bitcoin fully validating node"

[config."chain_mode"]
format = "plain"

[config."chain_mode".hvars.prune]
type = "uint"
constant = "0"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "0"
