name = "bitcoin-txindex-regtest"
extends = "bitcoin-regtest"
provides = ["bitcoin-chain-mode-regtest (= 1.0)", "bitcoin-fullchain-regtest"]
replaces = ["bitcoin-chain-mode-regtest"]
conflicts = ["bitcoin-chain-mode-regtest"]
summary = "Activates txindex on Bitcoin full node"

[config."chain_mode"]
format = "plain"

[config."chain_mode".hvars.prune]
type = "uint"
constant = "0"

[config."chain_mode".hvars.txindex]
type = "uint"
constant = "1"
