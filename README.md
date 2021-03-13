Cryptoanarchistic repository builder
====================================

Tooling for building a Debian repository containing interconnected, well-working applications.

![Logo of cryptoanarchistic Debian repository](docs/logo.svg)

Motivation
----------

* If you install `gnome-desktop`, `apt` also installs X server and configures everything properly
* If you install `gimp`, `apt` knows which libraries it needs
* If you install `apache`, `mysql`, `php` it works out-of-the-box

**Make Bitcoin apps work similarly**, examples:

* `sudo apt install btcpayserver` installs `btcpayserver`, `bitcoind`, `nginx`, `tor` connects them together and generates an `onion` address for you
* `sudo apt install electrs` is smart enough to turn off pruning
* `sudo apt install ridetheln` installs `lnd`, `bitcoind` without pruning, `nginx`, `tor`...
* All applications integrate nicely with existing Debian features (e.g. system database).

You should get the point at this point. :) It actually works now, if you setup the repository (read below).

However, there are still some pain points! The biggest ones is inconvenience when accessing your node remotely.
While the software was tested quite a lot and it seems to be working really well, it's not yet considered stable!

Supported applications
----------------------

<img src="https://en.bitcoin.it/w/images/en/2/29/BC_Logo_.png" width="64"> <img src="https://electrum.org/logo/electrum_logo.png" width="64"> <img src="https://raw.githubusercontent.com/lightningnetwork/lnd/master/logo.png" width="64"> <img src="https://avatars0.githubusercontent.com/u/31132886?s=200&v=4" width="64"> <img src="external-logos/thunderhub.svg" width="64">

Plus several internal tools to improve security and UX. Read below for the complete list.

If you want to try it out, see `docs/` directory to learn the details.

How to setup the beta Debian repository
---------------------------------------

**Please read the [docs](docs/user-level.md#what-you-need-to-know-before-installing-anything-from-this-repository) before you start!** Only Debian 10 (Buster) is currently tested, distributions based
on it (Ubuntu, Mint...) should work too and I'll be happy to recieve reports if you try them.

To use the produced repository you need to also setup Microsoft dotnet repository. Follow these steps
and don't forget to [verify fingerprints](https://gist.github.com/Kixunil/fb7300edcb8a8afc95e6b7b727b31f0d).

```
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | sudo apt-key add -
gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | sudo apt-key add -
echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/10/prod buster main' | sudo tee /etc/apt/sources.list.d/microsoft.list > /dev/null
echo 'deb [signed-by=3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C] https://deb.ln-ask.me/beta buster common local desktop' | sudo tee /etc/apt/sources.list.d/cryptoanarchy.list > /dev/null
sudo apt update
```

If you're setting up a dedicated full node, you may want to leave out `desktop` component in step 6.

Setting up on a dedicated hardware
----------------------------------

The recommended hardware for setting up this repository on a dedicated machin is Odroid H2 with at least 1TB NVMe SSD and 8GB of RAM.
We recommend more RAM to leave a room for future expansion.
It is also recommended to use a fan - it can get very hot otherwise!
The fan is very quiet even when the chain syncs - you can't hear it until your head is very close.

The newer versions of H2 have a network card which doesn't have [the driver](https://github.com/Kixunil/r8125) in Debian stable yet.
This repository offers `vendor` component which has the required driver package.
The recommended approach:

* Connect your phone over USB and set it to tethering
* Install Debian 10 from netinst
* `apt install gnupg`
* Add this repository with `vendor` component included
* `apt install r8125-dkms`
* Enable the newtwork interface in `/etc/network/interfaces`
* Disconnect the phone

Security features and limitations
---------------------------------

Obviously, whoever promises unhackable product is probably a scammer, so I'm not promising absolute security.
That being said this project has some interesting advantages over manual setup and some existing projects:

* Isolation of all services - the principle of least privilege is followed, each service runs under separate user
  with access restricted to the features it needs. For instance, the official BTCPayServer setup uses admin
  macaroon to access LND. This repository uses a special macaroon that prevents spending funds.
* Zero attack surface of Docker.
* Automated setup with declarative approach avoids bugs from typos and tiredness. Such issues can happen very easily
  when setting up manually.
* If you're a newbie, letting someone experienced in information security help you leads to better security.
* All packages have signatures checked, some even had code reviewed. To my knowledge various Docker setups don't
  check signatures, so this project should be safer.
* All official builds are performed in a dedicated Qubes VM, which should make it very hard to compromise.
* All GPG keys are checked with [`sqck`](https://github.com/Kixunil/sqck).
* Almost all packages are built deterministically

Known room for improvement:

* The builds could be made safer by reviewing Debian build tools and making sure they can't be compromised by bad
  inputs. Then reviewing all build systems to make sure they either don't execute custom build-time logic or
  isolate such login in a separate VM.
* `thunderhub` could be built deterministically
* **Neither** the code nor the output was widely reviewed by **independent** developers
* Automated backups could be added - this is high priority issue that should be solved in upcoming months. (#53)

That being said, I don't know of a comparable project that has significatnly better security. Would love to learn
if there is such.

Policy on Bitcoin consensus forks
---------------------------------

Including consensus code in a repository like this one is a delicate issue that has to be dealt with carefully.
To align the repository with the interests of its users, a clear policy must be declared and followed.
The goal of the policy of this repository is to minimize the risk by default while still allowing free choice.

As of today, the policy is this:

* No hard forks will update existing `bitcoind` binary unless they fix critial vulnerability (extremely improbable,
  a vulnerability fix would probably be a soft fork) or fix a known limitation of Bitcoin protocol such as data
  type limiting block time or height (highly improbable because it'll be non-issue next several decades).
* No soft fork that attempts to implement government-enforced censorship or similar kind of tampering with Bitcoin
  will be included, ever. Protections may be implemented (see below).
* No soft fork with very low support will replace existing `bitcoind` binary, but protections may be implemented (see
  below)
* A flag-day soft fork with dangerously high estimated support and expected value will upgrade the `bitcoind` binary
  by default. An alternative will be provided if it's expected to be controversial. It most likely will be provided
  anyway.
* In case of soft fork activation, a binary without this soft fork will be removed soon but not sooner than 100 blocks.
* Any sensible built-in split protection in an application will be turned on by default. A theoretical example would be
  BTCPayServer switching min confirmations to higher value around expected fork. If the protection didn't exist when the
  user installed the application, the protection will be turned on after update.
* No update will ever remove `bitcoind` or make it unoperable as such would endanger Lightning node(s). Additional
  effort to supply Lightning node(s) with transactions from competing chains will be seriously considered.
* Custom split protections may be implemented. These may include temporarily changing the configuration to require more
  confirmations unless the user explicitly turned off this protection.
* Custom alert system may be developed that will work together with the above and allow the user to take the risk.

**Policy specific to Taproot activation**

While the above should give good overview, this clarifies what will be done in case of Taproot:

Update: Speedy Trial

* This repository will contain a widely-accpeted version of Speedy Trial.
* If Speedy Trial succeeds, all future versions will have to be compatible with it (enforcing soft fork)
* If Speedy Trial fails, the original plan will be reconsidered
* Bumping min confirmations may be implemented but probably with a lower number (12 instead of 100).

Original plan (BIP8)

* Unless there will be wide, strong opposition to `LOT=true`, **this repository will contain a client with `LOT=true`
  by default.** Rationale: `LOT=false` risks wiping the funds if there's a sufficient number of users running `LOT=true`.
  Besides, all known users of this repository prefer `LOT=true`. (Please report if you use this repository and prefer
  `false`!)
* Bumping min confirmations in `lnd` will be researched and carefully considered.
* Bumping confirmations in BTCPayServer is probably difficult and surprising. Attempt will be made to coordinate with
  BTCPayServer devs.
* The planned alert system will be prioritized in the upcoming few months. It will display one precautionary alert message
  on upgrade unless the upgrade is performed long after miner activation. Then a next one around timeout unless Taproot is
  active for a while already.
* Upgrading to `bitcoind` with Taproot support will have the highest priority (except critial security vulnerabilities),
  followed by updating all applications implementing split protections.

**Important: this policy is young and may be refined!** Please come here again later to check if it's still the same.
Feel free to submit your feedback.
Note: as predicted it was already updated to account for Speedy Trial. 

About this **GitHub** repository
--------------------------------

This **GitHub** repository contains a set of makefiles and other tools to build the **Debian** repository.
It's useless to you unless you are trying to build it on your own or help with development.

Build Instructions
------------------

The only officially supported OS for building and running is currently **Debian 10 (Buster)**!
It may work on recent version of Ubuntu and derived systems, but it's not tested. Contributions
(trying it and reportin) welcome!
This part is relevant only if you want to develop the repository or build it on your own.

Only needed for the first time:

```
git clone https://github.com/Kixunil/cryptoanarchy-deb-repo-builder
cd cryptoanarchy-deb-repo-builder
sudo apt-get install cargo npm ruby-mustache
# Requires the latest debcrafter version
cargo install --git https://github.com/Kixunil/debcrafter
PATH=$PATH:~/.cargo/bin
cargo install cfg_me
make BUILD_DIR=$PWD/build build-dep
```

For all subsequent builds:
```
make BUILD_DIR=$PWD/build
```

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
- [x] btc-transmuter
- [x] btc-transmuter-system-mainnet
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
- [x] ridetheln-lnd-system-mainnet
- [x] thunderhub
- [x] thunderhub-system-mainnet
- [x] btc-rpc-explorer
- [x] btc-rpc-explorer-mainnet
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
- [x] lnpbp-testkit (framework for testing LNP/BP applications)
- [x] remir (a simple server for controlling IR devices; not freedom related, but why not?)
- [ ] translations
- [x] all services for regtest
- [ ] all services for signet
- [ ] all services for testnet

License
-------

The exact license of this project is not decided/creatd yet.
I plan to make it as compatible with Voluntaryism as possible.
It'll probably be very similar to GPL but without mandatory disclosure of source code.
(That means you can refrain from disclosing the source but you may not prevent other people from copying, inspecting and modifying the binary unless they agreed to not do it in written private contract.)
Modification, redistribution, and commercial use will be allowed.

In the meantime I hereby publicly declare that I will not seek to sue people using this project regarding copyright law unless they sue me or anyone else regarding the copyright law first.
Especially, but not limited to the contributors to this project.
To the best of my knowledge, this public declaration is legally binding for me as a Slovak citizen and I intend it to be.
I specifically want any my attempts at suing to be void if unprovoked.

Moreover, feel free to publicly criticize me for doing anything incompatible with the philosophy of Voluntaryism.

By contributing to this repository you agree with the general direction of licensing.
If you have questions about this, don't hessitate to contact me.
