name = "lnd"
architecture = "any"
summary = "Lightnning Network Daemon"
recommends = ["bitcoin-mainnet | bitcoin-regtest, lnd-system-mainnet | bitcoin-regtest, lnd-system-regtest | bitcoin-mainnet, lnd-system-both | lnd-system-mainnet | lnd-system-regtest"]
suggests = ["lncli"]
add_files = ["lnd /usr/bin", "lib/bash.sh /usr/share/lnd/lib", "get_external_addr.sh /usr/share/lnd"]
long_doc = """The Lightning Network Daemon (lnd) - is a complete implementation of a
Lightning Network node. lnd has several pluggable back-end chain services
including btcd (a full-node), bitcoind, and neutrino (a new experimental light
client). 

Note that this is just a binary and does nothing unless configured and
executed. Consider using lnd-system-mainnet to automatically manage the
daemon using main Bitcoin network."""
