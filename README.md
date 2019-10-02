Cryptoanarchistic repository builder
====================================

Tooling for building a Debian repository containing interconnected, well-working applications.

About
-----

This repository contains a set of makefiles and other tools to build a debian repository full
of freedom and privacy-oriented services and applications. It aims to enable hassle-free
deployment and configuration suitable for servers and the desktops. It achieves this by
leveraging full power of great Debian packaging system. Currently the repository contains
only Bitcoin-related stuff, but the intention is to add other freedom-oriented stuff later.

The main components of the resulting packages are:

* packages containing binaries - they do nothing after installation
* service packages - these ensure configuration and launching of the services
* interface packages - whenever an application depends on certain service being present, the
  package depends on a virtual interface package

Debconf is used as the preferred way to (re)configure packages, but there are some exceptions.
Sometimes an application depends on another application being configured in certain way (e.g.
electrs depends on bitcoind to *not* prune the timechain). This is expressed in the packaging
too. While the system administrator can still break the system obviously, a normal user just
installs whatever he needs and lets it run on its own. Even in the case of control freaks,
the consistency of configuration is maintained (e.g. changing RPC port of one package causes
change in the other package).

Build Dependencies
------------------
Only needed first time:

`make build-dep`

Building
--------

`make`

Important note
--------------

This project is work in progress and is missing tons of packages! Do not use in production!

(Probably incomplete) TODO list:

- [x] bitcoind
- [x] bitcoin-mainnet
- [x] bitcoin-mainnet-fullchain
- [x] bitcoin-mainnet-txindex
- [x] bitcoin-mainnet-zmq
- [x] bitcoin-mainnet-p2p (virtual, Bitcoin P2P protocol)
- [x] bitcoin-rpc-proxy (upstream needs patches)
- [ ] bitcoin-rpc-proxy-mainnet
- [ ] bitcoin-timechain-mainnet (public timechain RPC calls)
- [ ] electrs
- [ ] electrs-mainnet
- [ ] electrumx
- [ ] electrumx-mainnet (low priority)
- [ ] electrum-server-mainnet (virtual, electrum server implementation)
- [ ] wasabi-mainnet-trustless
- [ ] wasabi
- [ ] nbxplorer
- [ ] nbxplorer-mainnet
- [ ] btcpayserver
- [ ] btcpayserver-mainnet
- [ ] lnd
- [ ] lnd-system-mainnet
- [ ] eclair
- [ ] eclair-system-mainnet
- [ ] eclair-turbo
- [ ] eclair-turbo-system-mainnet
- [ ] ln-system-mainnet (virtual, provides system-wide Lightning Network implementation)
- [ ] multiuser-ln (completely new application allowing multiple users to share a LN implementation)
- [ ] multiuser-ln-mainnet
- [ ] liblightning (a completely new library abstracting away implementation details and allowing multiple wallets)
- [ ] ln-contacts (a completely new application providing contact list for Lightning Network nodes)
- [ ] ln-dialog (partialy done in qpay, a simple dialog which shows whenever the user attempts to pay, create invoice or open LNURL)
- [ ] qpay-rpc-service
- [ ] qpay-client
- [ ] ln-mime (makes sure to register appropriate mime types and launch correct application)
- [ ] remote-service-bridge (a framework for securely bridging services to remote computers, needs to be written)
- [ ] translations
- [ ] all services for testnet (`s/mainnet/testnet/` should suffice)
