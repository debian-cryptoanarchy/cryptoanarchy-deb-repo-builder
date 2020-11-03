name = "bitcoin-rpc-proxy"
architecture = "any"
summary = "Bitcoin RPC proxy"
depends = ["${shlibs:Depends} ${misc:Depends}"]
recommends = ["bitcoin-mainnet | bitcoin-regtest, bitcoin-rpc-proxy-mainnet | bitcoin-regtest, bitcoin-rpc-proxy-regtest | bitcoin-mainnet, bitcoin-rpc-proxy-both | bitcoin-rpc-proxy-mainnet | bitcoin-rpc-proxy-regtest"]
add_files = ["/usr/bin/btc_rpc_proxy"]
add_manpages = ["target/man/btc_rpc_proxy.1"]
long_doc = """This is a proxy made specifically for bitcoind to allow finer-grained control
of permissions. It enables you to specify several users and for each user the
list of RPC calls he's allowed to make.

This is useful because bitcoind allows every application with password to make
possibly harmful calls like stopping the daemon or spending from wallet (if
enabled). If you have several applications, you can provide the less trusted
ones a different password and permissions than the others using this project.

There's another interesting advantage: since this is written in Rust, it might
serve as a filter for some malformed requests which might be exploits. But I
don't recommend relying on it!"""
