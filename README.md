# Cryptoanarchistic repository builder

Securely install Bitcoin and freedom-related apps with a single `apt install` command, no manual configuration or launching required!

![Logo of cryptoanarchistic Debian repository](docs/logo.svg)


* [How to setup](#how-to-setup-the-beta-debian-repository)
* [Bug reporting](#bug-reporting)
* [Documentation](docs/README.md)
* [Development](#development-and-contributions)


## About

This is an (extra)ordinary Debian repository that you can add to your Debian 11 system (see below).
It integrates deeply into the OS giving you great UX and security.

Keep in mind it's still considered beta even though very stable and usable.
There's intensive work going on to make it stable soon.

### Upgrading to Debian 11 - Bullseye

**Please follow these instructions carefully to ensure smooth upgrade!**

All commands in this guide assume you're logged in as `root`. If not, log in as root or use `sudo` in front of each.

Consider also reading the [Debian upgrade guide](https://www.debian.org/releases/bullseye/amd64/release-notes/ch-upgrading.en.html),
however you do not need to uninstall any CADR packages/sources as suggested in section 4.2 - direct upgrade is supported by CADR!

#### Preparation

0. Make sure you have enough space.
1. Run `apt update` and `apt dist-upgrade`, possibly also `apt autoremove --purge` and `apt clean`
2. A catastrophic failure is very unlikely but it's still recommended to backup the channels and stopping LND immediatelly afterwards by running `systemctl stop lnd-system-mainnet`
3. Edit `/etc/apt/sources.list` and all the files in `/etc/apt/sources.list.d` according to these rules:
    * Change `buster/updates` to `bullseye-security`
    * Change `https://packages.microsoft.com/debian/10/prod buster` to `https://packages.microsoft.com/debian/11/prod bullseye` - note *also* the 10 to 11 change!
    * Change all the remaining instances of `buster` to `bullseye`. The vim command `:%s/buster/bullseye/` can be used.
4. Run `apt update`

#### Running upgrade

Run `apt dist-upgrade`. You may want to check for suspicious changes such as removing packages that should be installed, however this is unlikely to happen.
The process is interactive and you will be shown changelog (press `q` to quit it), asked about `glibc` upgrade (select yes) and about restarting of the services (yes is recommended).
This step takes around 30 minutes on usual hardware.

You may be asked about configuration changes.
If you changed a configuration file that is also changed by the upgrade you'll be asked what to do about it.
Keeping the file as-is (`N` option) is the safest but if you're unsure select diff to see the difference.
Just note that `sudo` configuration is one of the changed files so be careful to not lock yourself out!

#### Finishing touches

If you've stopped LND you can start it now: `systemctl start lnd-system-mainnet`

During upgrade you'll be reminded to upgrade postgres cluster. Run these commands:

1. `pg_dropcluster --stop 13 main` - **WARNING: this command is dangerous! It's recommended to prevent it from being in history by putting a space in front of it.**
2. `pg_upgradecluster 11 main`
3. After verifying that everything works: `pg_dropcluster --stop 11 main`

You can also cleanup unneeded packages:

1. `apt autoremove --purge`
2. `apt clean`

Finally consider rebooting as you will get a new kernel. There's no annoying window forcing you to do so though. ;)

## Supported applications

<img src="https://en.bitcoin.it/w/images/en/2/29/BC_Logo_.png" width="64"> <img src="https://electrum.org/logo/electrum_logo.png" width="64"> <img src="https://raw.githubusercontent.com/lightningnetwork/lnd/master/logo.png" width="64"> <img src="https://avatars0.githubusercontent.com/u/31132886?s=200&v=4" width="64"> <img src="external-logos/thunderhub.svg" width="64">

... and more! See the end of this README for the complete list or [user documentation](docs/user-level.md) to learn more about them.

## How to setup the beta Debian repository

**WARNING: This project is too user friendly!
This is not a joke, several people were already confused by not having to manually run and configure things.**

**Please read [five things to know before you start using this](#five-things-to-know-before-you-start-using-this) to avoid confusion.**

Only Debian 11 (Bullseye) is currently tested, distributions based
on it (Ubuntu, Mint...) could work too but may be less reliable.

It's highly recommended to use decent hardware: at least 8GB of RAM and 1TB SSD (ideally NVMe).
Your experience and the experience of your peers routing LN transactions through your node may suck otherwise!

To use the produced repository you need to also setup Microsoft dotnet repository. Follow these steps
and don't forget to [verify fingerprints](https://gist.github.com/Kixunil/fb7300edcb8a8afc95e6b7b727b31f0d).

```
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | sudo apt-key add -
gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | sudo apt-key add -
echo 'deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/11/prod bullseye main' | sudo tee /etc/apt/sources.list.d/microsoft.list > /dev/null
echo 'deb [signed-by=3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C] https://deb.ln-ask.me/beta bullseye common local desktop' | sudo tee /etc/apt/sources.list.d/cryptoanarchy.list > /dev/null
sudo apt update
```

If you're setting up a dedicated full node, maybe [on dedicated hardware](docs/dedicated-hardware.md), you may want to leave out `desktop` component in step 6.

You can now install the desired applications using e.g. `apt install btcpayserver`.
Don't worry about the dependencies. :)
Read short [docs on each application](docs/user-level.md#using-applications) you plan to use.

## Five things to know before you start using this

* Do **not** attempt to configure anything - it will just work
* Do understand that `bitcoind` and other services will run automatically **immediately after installation and after each boot**.
* **By default, the LND wallet is created automatically after installation and the seed is stored in /var/lib/lnd-system-mainnet/.seed.txt**
* Do **not** attempt to configure anything - it will just work
* Make sure you have at least 400 GB of free space

## Bug reporting

Please report any issues with the software available here to [this project](https://github.com/debian-cryptoanarchy/cryptoanarchy-deb-repo-builder/issues/new/choose).
E.g. if there's a problem with `btcpayserver` do **not** report it to the BTCPayServer developers but [here](https://github.com/Kixunil/cryptoanarchy-deb-repo-builder/issues).
If the problem is found to be in the software itself it will be forwarded, do not worry about this.

## Using third party repositories and packages

Using additional repositories/packages beyond the official Debian repositories and this one may be dangerous!
Especially upgrading packages that are otherwise present in Debian or this repository may lead to breakages.
An example of a known problem is adding nodejs repository - don't do it!

Reach out for help with using additional software that requires higher dependency versions.

It should be safe to add repositories that are explicitly tested to work with Debian Bullseye and this repository.

## Security

No project is 100% secure. There are more secure ones and less secure ones.
This one is very secure and is being improved constantly.

Read more in the [security documentation](docs/security).

## Policy on Bitcoin consensus forks

Including consensus code in a repository like this one is a delicate issue that has to be dealt with carefully.
To align the repository with the interests of its users, a [clear policy](docs/security/fork_policy.md) must be declared and followed.

## About this **GitHub** repository

This **GitHub** repository contains a set of makefiles and other tools to build the **Debian** repository.
It's useless to you unless you are trying to build it on your own or help with development.

## Development and contributions

**Important:** This is intended for developers and researchers only!
Regular users should use [the built repository as presented above](#how-to-setup-the-beta-debian-repository).

The [development documentation](docs/developer) is not great now.
Please open an issue if you are interested in development and I will try to fill in the relevant details.

## Supported and planned applications

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

## License

The exact license of this project is not decided/created yet.
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
If you have questions about this, don't hesitate to contact me.
