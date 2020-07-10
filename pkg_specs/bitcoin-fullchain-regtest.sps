name = "bitcoin-fullchain-regtest"
extends = "bitcoin-regtest"
provides = ["bitcoin-chain-mode-regtest (= 1.0)"]
replaces = ["bitcoin-chain-mode-regtest"]
conflicts = ["bitcoin-chain-mode-regtest"]
summary = "Bitcoin fully validating node"

[config."chain_mode"]
format = "plain"

[config."chain_mode".hvars.prune]
type = "uint"
constant = "0"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "0"
