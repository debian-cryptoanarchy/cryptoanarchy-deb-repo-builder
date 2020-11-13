name = "bitcoin-cli"
architecture = "any"
summary = "Bitcoin CLI"
suggests = ["bitcoin-mainnet | bitcoin-regtest"]
add_files = ["bin/bitcoin-cli /usr/lib/bitcoin-cli", "xbitcoin-cli /usr/share/bitcoin-cli"]
add_manpages = ["share/man/man1/bitcoin-cli.1"]
long_doc = """bitcoin-cli is a tool used for managing bitcoind from the command line. This package
also contains a wrapper used to connect to the system-wide bitcoind by default.
You can still use -connect -rpcport -rpccookiefile -rpcuser and -rpcpassword to access a
different bitcoind."""

[alternatives."/usr/share/bitcoin-cli/xbitcoin-cli"]
name = "bitcoin-cli"
dest = "/usr/bin/bitcoin-cli"
priority = 100

[alternatives."/usr/lib/bitcoin-cli/bitcoin-cli"]
name = "bitcoin-cli"
dest = "/usr/bin/bitcoin-cli"
priority = 50
