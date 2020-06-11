name = "electrs"
architecture = "any"
summary = "An efficient re-implementation of Electrum Server in Rust"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["electrs-mainnet | electrs-regtest"]
add_files = ["target/release/electrs usr/bin"]
add_manpages = ["target/man/electrs.1"]
long_doc = """The motivation behind this project is to enable a user to run his own Electrum
server, with required hardware resources not much beyond those of a full node.
The server indexes the entire Bitcoin blockchain, and the resulting index 
enables fast queries for any given user wallet, allowing the user to keep
real-time track of his balances and his transaction history using the Electrum
wallet. Since it runs on the user's own machine, there is no need for 
the wallet to communicate with external Electrum servers, thus preserving
the privacy of the user's addresses and balances."""
