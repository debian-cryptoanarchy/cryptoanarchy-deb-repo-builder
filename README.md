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
* All applications should integrate nicely with existing Debian features (e.g. system database).

You should get the point at this point. :) It actually works now, if you setup the repository (read below).

However, there are still some pain points! The biggest ones is inconvenience when accessing your node remotely.
Also, warning: beta-quality software!!!

Supported applications
----------------------

<img src="https://en.bitcoin.it/w/images/en/2/29/BC_Logo_.png" width="64"> <img src="https://electrum.org/logo/electrum_logo.png" width="64"> <img src="https://raw.githubusercontent.com/lightningnetwork/lnd/master/logo.png" width="64"> <img src="https://avatars0.githubusercontent.com/u/31132886?s=200&v=4" width="64"> <img src="external-logos/thunderhub.svg" width="64">

Plus several internal tools to improve security and UX. Read below for the complete list.

If you want to try it out, see `docs/` directory to learn the details.

How to setup the beta Debian repository
---------------------------------------

Please read the [docs](docs/) before you start! Only Debian 10 (Buster) is currently tested, distributions based
on it (Ubuntu, Mint...) should work too and I'll be happy to recieve reports if you try them.

To use the produced repository you need to also setup Microsoft dotnet repository. Follow these steps
and don't forget to [verify fingerprints](https://gist.github.com/Kixunil/fb7300edcb8a8afc95e6b7b727b31f0d).

1. `gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C`
2. `gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF`
3. `gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | sudo apt-key add -`
4. `gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | sudo apt-key add -`
5. `echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/10/prod buster main' | sudo tee /etc/apt/sources.list.d/microsoft.list > /dev/null`
6. `echo 'deb https://deb.ln-ask.me buster common local desktop' | sudo tee /etc/apt/sources.list.d/cryptoanarchy.list > /dev/null`
7. `sudo apt update`

If you're setting up a dedicated full node, you may want to leave out `desktop` component in step 6.

Security features and limitations
---------------------------------

Obviously, whoever promises unhackable product is probably a scammer, so I'm not promising absolute security.
That being said this project has some interesting advantages over manual setup and some existing projects:

* Isolation of all services - the principle of least privilege is followed, each service runs under separate user
  with access restricted to the features it needs. For instance, the official BTCPayServer setup uses admin
  macaroon to access LND. This repository uses a special macaroon that prevents spending funds.
* Zero attack surface of Docker.
* Automated setup with declarative approach avoids bugs from typos and tiredness. Such can happen very easily when
  setting up automatically.
* If you're a newbie, letting someone experienced in information security help you leads to better security.
* All packages have signatures checked, some even had code reviewed. To my knowledge various Docker setups don't
  check signatures, so this project should be safer.
* All official builds are performed in a dedicated Qubes VM, which should make it very hard to compromise.
* All GPG keys are checked with [`sqck`](https://github.com/Kixunil/sqck).
* Most packages are built deterministically

Known room for improvement:

* The builds could be made safer by reviewing Debian build tools and making sure they can't be compromised by bad
  inputs. Then reviewing all build systems to make sure they either don't execute custom build-time logic or
  isolate such login in a separate VM.
* The remaining packages (`electrs`, `ridetheln`, `thunderhub`) could be built deterministically
* **Neither** the code nor the output was widely reviewed by independent developers
* Automated backups could be added - this is high priority issue that should be solved in upcoming months. (#53)

That being said, I don't know of a comparable project that has significatnly better security. Would love to learn
if there is such.

About this **GitHub** repository
--------------------------------

This **GitHub** repository contains a set of makefiles and other tools to build the **Debian** repository.
It's useless to you unless you are trying to build it on your own or help with development.

Build Dependencies
------------------

The only officially supported OS for building and running is currently **Debian 10 (Buster)**!
It may work on recent version of Ubuntu and derived systems, but it's not tested. Contributions
(trying it and reportin) welcome!
This part is relevant only if you want to develop the repository or build it on your own.
Only needed the first time:

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

Supported and planned applications
----------------------------------

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
- [x] lndconnect a CLI tool for creating lndconnect link
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
