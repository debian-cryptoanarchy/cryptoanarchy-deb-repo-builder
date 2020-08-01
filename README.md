Cryptoanarchistic repository builder
====================================

Tooling for building a Debian repository containing interconnected, well-working applications.

![Logo of cryptoanarchistic Debian repository](docs/logo.svg)

Motivation
----------

* If you install `gnome-desktop` `apt` also installs X server and configures everything properly
* If you install `gimp` `apt` knows which libraries it needs
* If you install `apache`, `mysql`, `php` it works out-of-the-box

**We want the same to work for Bitcoin apps**, examples:

* `sudo apt install btcpayserver` should install `btcpayserver`, `bitcoind`, `nginx`, `tor` connect them together and generate an `onion` address for you
* `sudo apt install electrs` should be smart enough to turn off pruning
* `sudo apt install ridetheln` should install `lnd`, `bitcoind` without pruning, `nginx`, `tor`...

You should get the point at this point. :) It actually works now, if you setup the repository.

However, there are still some pain points! The biggest ones is inconvenience when accessing your node remotely. Also, warning: beta-quality software!!!

Supported applications
----------------------

<img src="https://en.bitcoin.it/w/images/en/2/29/BC_Logo_.png" width="64"> <img src="https://electrum.org/logo/electrum_logo.png" width="64"> <img src="https://raw.githubusercontent.com/lightningnetwork/lnd/master/logo.png" width="64"> <img src="https://avatars0.githubusercontent.com/u/31132886?s=200&v=4" width="64"> <img src="external-logos/thunderhub.svg" width="64">

Plus several internal tools to improve security and UX. Read below for the complete list.

If you want to try it out, see `docs/` directory to learn the details.

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
* configuration-extension packages - they make sure some combinations of other packages are
  configured properly (see below)
* interface packages - whenever an application depends on certain service being present, the
  package depends on a virtual interface package

Debconf is used as the preferred way to (re)configure packages, but there are some exceptions.
Sometimes an application depends on another application being configured in certain way (e.g.
electrs depends on bitcoind to *not* prune the timechain). This is expressed in the packaging
too. While the system administrator can still break the system obviously, a normal user just
installs whatever he needs and lets it run on its own. Even in the case of control freaks,
the consistency of configuration is maintained (e.g. changing RPC port of one package causes
change in the other package).

Produced repository and its security limitations
------------------------------------------------

There's [an official experimental repository](https://deb.ln-ask.me) for this project. It should
work, but all the limitations of this project apply. Further, security is limited due to these
factors:

* The buld is performed in a **single** Qubes VM that **is** connected to the Internet.
* **Not all** signatures are checked
* Build is **not** deterministic
* **Neither** the code nor the output was widely reviewed by independent developers
* `tor-hs-patch-config` and `selfhost-onion` don't work with apparmor! Boot with `apparmor=0`
  kernel param or don't use! See #72

Keep in mind however, that this project may already beat others in terms of security thanks to
cautious use of Qubes OS. There are already plans to improve this further.

Known functional limitations/bugs
---------------------------------

As any other software, this one is not perfect. Look at the issues to see all of them, here are
some highlights that you may want to know about before you try it:

* No automated backups #53

Build Dependencies
------------------

The only officially supported OS for building and running is currently **Debian 10 (Buster)**!
It may work on recent version of Ubuntu and derived systems, but it's not tested. Contributions
(trying it and reportin) welcome!
This part is relevant only if you want to develop the repository or verify it on your own.
Only needed first time:

```
sudo apt-get install cargo npm ruby-mustache
# Required version >= 0.1.1
cargo install --bin gen_deb_repository --git https://github.com/Kixunil/debcrafter
cargo install cfg_me
make build-dep
```

Building
--------

`make`

Important note
--------------

This project is work in progress and is missing important features! Beta-quality software
- use with caution!

(Probably incomplete) TODO list:

- [x] bitcoind
- [x] bitcoin-mainnet
- [x] bitcoin-pruned-mainnet (provides bitcoin-chain-mode-mainnet) DO NOT DEPEND ON THIS ONE!!!
- [x] bitcoin-fullchain-mainnet (provides bitcoin-chain-mode-mainnet)
- [x] bitcoin-txindex-mainnet (provides bitcoin-chain-mode-mainnet)
- [x] bitcoin-chain-mode-mainnet makes sure to consistently select pruned/non-pruned/txindex
- [x] bitcoin-zmq-mainnet
- [x] bitcoin-cli (with a wrapper that uses bitcoin-mainnet by default)
- [ ] bitcoin-p2p-mainnet (virtual, Bitcoin P2P protocol)
- [x] bitcoin-rpc-proxy
- [x] bitcoin-rpc-proxy-mainnet
- [x] bitcoin-timechain-mainnet (public timechain RPC calls)
- [x] electrs
- [x] electrs-mainnet
- [ ] electrs-esplora
- [ ] electrs-esplora-mainnet
- [ ] esplora
- [ ] esplora-mainnet
- [ ] electrumx (low priority)
- [ ] electrumx-mainnet (low priority)
- [ ] electrum-server-mainnet (virtual, electrum server implementation)
- [x] electrum (desktop package without .desktop file)
- [x] electrum-trustless-mainnet (desktop package configured to use electrum-server-mainnet)
- [ ] wasabi-trustless-mainnet
- [ ] wasabi (desktop package without .desktop file)
- [x] nbxplorer
- [x] nbxplorer-mainnet (no integration into nginx yet)
- [x] btcpayserver
- [x] btcpayserver-system-mainnet
- [x] btcpayserver-lnp-system-mainnet (connects LND with BTCPayServer)
- [x] btcpayserver-system-selfhost-mainnet (automatically sets up BTCPayServer with selfhost framework)
- [x] selfhost (a tooling/framework for selfhosting applications easily)
- [x] selfhost-nginx (nginx gateway for selfhost)
- [x] selfhost-clearnet (sets up clearnet domain)
- [x] selfhost-clearnet-certbot (automatically sets up Let's Encrypt for selfhost-clearnet)
- [x] selfhost-onion (automatically sets up onion address for selfhost)
- [x] lnd
- [x] lnd-system-mainnet
- [x] lnd-auto-unlock
- [x] lnd-unlocker-system-mainnet
- [x] lnd-genmacaroon (generates additional macaroons - currently only invoice+readonly for use with btcpay)
- [x] lnd-genmacaroon-mainnet
- [x] lncli (with a wrapper that uses lnd-system-mainnet by default)
- [ ] eclair
- [ ] eclair-system-mainnet
- [ ] eclair-turbo
- [ ] eclair-turbo-system-mainnet
- [ ] eclair-rpc-proxy
- [ ] eclair-rpc-proxy-mainnet
- [ ] eclair-invoice-mainnet (virtual, I guess)
- [ ] ln-system-mainnet (virtual, provides system-wide Lightning Network implementation)
- [x] ridetheln
- [x] ridetheln-system
- [x] ridetheln-system-selfhost
- [x] ridetheln-lnd-system-mainnet
- [x] thunderhub
- [x] thunderhub-system-mainnet
- [x] thunderhub-system-selfhost-mainnet
- [x] btc-rpc-explorer
- [x] btc-rpc-explorer-mainnet
- [x] btc-rpc-explorer-selfhost-mainnet
- [ ] lighter
- [ ] multiuser-ln (completely new application allowing multiple users to share a LN implementation)
- [ ] multiuser-ln-mainnet
- [ ] liblightning (a completely new library abstracting away implementation details and allowing multiple wallets) - maybe just use lighter instead
- [ ] ln-contacts (a completely new application providing contact list for Lightning Network nodes)
- [ ] ln-dialog (partialy done in qpay, a simple dialog which shows whenever the user attempts to pay, create invoice or open LNURL)
- [ ] qpay-rpc-service
- [ ] qpay-client
- [ ] ln-mime (makes sure to register appropriate mime types and launch correct application)
- [ ] remote-service-bridge (a framework for securely bridging services to remote computers, needs to be written)
- [ ] samourai-dojo
- [ ] samourai-dojo-mainnet
- [ ] joinmarket
- [ ] joinmarket-mainnet
- [ ] translations
- [x] all services for regtest
- [ ] all services for signet
- [ ] all services for testnet
