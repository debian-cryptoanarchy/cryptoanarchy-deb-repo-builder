# User-level documentation of Cryptoanarchy Debian Repository

## What's the point

The work of any operating system depends on so called "services", programs that are run in the background and control many of the functions of the operating systems and other programs. Those are the programs that provide interface between the hardware and software (called drivers), index files for quick search of your documents, manage the way your audio is mixed before it gets to your speakers and many others. 

You don't need to know many of the system services work and which programs depend on them, but it's important that their presence is vital for the system. In a popular GNU/Linux distributions such as Debian rely on a package manager that automatically figures out which services need to be installed and configured whenever you choose a new application to be installed on your computer.

We believe that this is the way bitcoin and cryptocurrency related software should behave as well, but the current situation is different. The user is often referred to a GitHub repository, where in the described installation is tedious manual procedure prone to errors and security holes arising from misconfiguration or failure to verify the software properly. 

This repository was made to address this issue and allow to install cryptocurrency software stack automatically. It aims to create the required package files installable with Debian package manager. 

Yes, installing any Bitcoin/freedom-related application is now going to be as easy as installing VLC. It'll be possible to use GUI or simple `apt` command.

## What you need to know before installing anything from this repository

(TL;DR below)

**The project is still work in progress!** For the time-being a basic admin skills going to be of a great help. It is often faster and more illustrative to provide the code via commands that you paste to your terminal window, than writing the instruction for GUI. 

Also, any feedback you might provide is appreciated. You can do so by opening an issue on our GitHub repository page.

With that out of the way, let's talk about the general structure first. There are many packages that are connected in various ways. They have proper dependency relationships declared that make sure you don't install a package without an important part. So for the most part, you can just blindly install packages. There are a few important things you need to have in mind, though!

* Only Debian 10 is currently officially supported. Ubuntu and derivatives should work, but we can't be sure. Please report any issues you find.
* Beware: as explained above, bitcoin and all related services will run automatically right after boot until you shutdown the computer!
* Some packages require bitcoin **without pruning** to be configured. And they will do it automatically. That means, if you have less than 350 GB of free space, you should be very careful about what you install! Basically, the only (somewhat) useful packages that you can install now are `bitcoin-rpc-proxy`, `nbxplorer`, `btcpayserver`, `selfhost*`, `tor-hs-patch-config`
* The data does **not** go to your home directory, but under `/var/lib`. Make sure you use a large enough partition or additional disk mounted to the `/var/lib` partition (configurable in `/ets/fstab`). In case you are not able to do it for some reason, e.g.
 you have partitioned your disks to have big home partition and small system partition, you will have to set a different path **using debconf** - read below.
* Contrary to the convention, all the configuration files are auto-generated and **must not** be edited! If you need to tune something, the best place to do that is using debconf. The second best place is filing a request for the setting on GitHub, if it isn't in debconf yet. If you can't wait for the implementation, place it into an appropriate `conf.d` directory and re-run debconf. However continue reading!
* Any change to configuration requires running `dpkg-reconfigure PACKAGENAME` `electrs` and `bitcoin-rpc-proxy` are smarter and they only need `systemctl restart`.
* Some configuration is special in being controlled by certain packages being or not being installed. The most important case is configuration of pruning/non-pruning/txindex of bitcoind. If you want to change the setting, you must install the appropriate package: `bitcoin-pruned-mainnet`, `bitcoin-fullchain-mainnet`, `bitcoin-txindex-mainnet`. Naturally, **only one of them can be installed at the same time**. Further **some other packages, like `electrs` require specific package to be installed!** Note however, that `txindex` implies `fullchain`, so having it installed is fine for `electrs` and such. Obviously, `pruned` can't be installed with `electrs`. While there are ways to hack this, just don't. You will run into a lot of trouble. The point of this repository is to (hopefully) never break.
* When you change the configuration of paths, they don't get moved automatically! This will be fixed eventually, just be careful around that for now.
* Many dependencies are specified using `Recommends`, which means installing stuff with `--no-install-recommends` will work, but won't be very useful.
* Lot of stuff here is intended for servers. While it can be used on desktop and the goal is to make it useful there eventually, it will take many months to get there.
* The server stuff is still considered advanced topic - read (the end of) the admin docs!
* `btcpayserver` and `ridetheln` (a better name for RTL, AKA Ride The Lightning) use a custom system of integration into `nginx` in order to get an onion domain, or even a clearnet domain with HTTPS certificate automatically. This is really great for user experience, but may be surprising to people who don't read the docs!
* If you want a clearnet domain, install `selfhost-clearnet` package. This will skip `clearnet-onion` unless you install both, of course. This operation can **not** be performed non-interactively, without presetting debconf!
* If you install `bitcoin-regtest`, all following packages will install regtest version (e.g. installing `lnd` will install `lnd-system-regtest`). If you have `bitcoin-mainnet` and `bitcoin-regtest` and would like install only one package, just install the single version you want e.g. `lnd-system-mainnet`

If all that seems too long to you, here's a short version:

* **Keep in mind the project is beta**
* **By default, the LND wallet is created automatically after installation and the seed is stored in /var/lib/lnd-system-mainnet/.seed.txt**
* Make sure you have at least 350 GB of free space
* Do **not** run `apt` with any funny switches
* Do **not** attempt to configure anything - it will just work
* Do **not** touch any configuration
* Do understand that bitcoind and other services will run automatically
* Read (the end of) the admin docs to understand server software (btcpayserver, ridetheln)
* When in doubt, ask on GitHub

Happy bitcoining!

## Using applications

This section explains specifics of various applications packaged in the repository. 

Many of the application are hosted on a specific port of your server. By default they are only exposed to the localhost interface, i.e. IP address 127.0.0.1, that is accessible only from the server machine. In case you'd like to access the service on other machine (e.g. your laptop) the simplest way is to use the port forwarding. This can be done using `ssh` option `-L [bind_address:]port:host:hostport`, e.g. to bind port 50001 of `electrs` log in to your server using the command `ssh -L 127.0.0.1:50001:127:0.0.1:50001 <server>`, where `<server>` is replaced by the hostname or ip address of your server.

### bitcoind and bitcoin-cli

#### About

`bitcoind` is the full node implementation, the heart of Bitcoin ecosystem.
`bitcoin-cli` package/command can be used to control `bitcoind` from command line.

#### Usage

* **Important: unless you (directly or indirectly) install bitcoin-fullchain-$network or bitcoin-txindex-$network the node will be pruned by default.
  Some packages (electrs, lnd, ...) depend on fullchain, so they won't break.
  To avoid problems, do NOT install the packages one-by-one - install all desired packages using a single `apt install` command.**
* If you want to change the location of datadir install `bitcoin-mainnet` with `DEBIAN_PRIORITY=medium` and answer the question.
* Check `btc-rpc-explorer` package for a nice graphical interface.
* You need `sudo` to run `bitcoin-cli`, group support not implemented yet, PRs welcome.
* `bitcoin-cli` is not actual binary, it forwards your commands to the real binary in order to work out of the box
* If `bitcoin-cli` detects that you don't have the permission for *full* access to `bitcoind` it will use public:public if you have `bitcoin-timechain-$network` installed.
* `bitcoin-tx` is not packaged yet because I'm not sure into which package it should go
* Use `bitcoin-cli -chain=regtest` for regtest (assuming `bitcoin-regtest` is installed).

### bitcoin-rpc-proxy

#### About

Protects `bitcoind` from other applications if they become compromised.

#### Usage

* There's not much to do with it, but you can add new users by adding a file to `/etc/bitcoin-rpc-proxy-mainnet/conf.d` and then restarting (`systemctl restart`)
* Take a look at `bitcoin-timechain-mainnet` to get a read-only user installed with `public:public` credentials.

### electrs

#### About

An efficient re-implementation of Electrum server in Rust. A perfect choice for user-friendly personal use.

#### Usage

* ~~`electrum-trustless-mainnet` depends on it, so if you install it on desktop, it should work~~ Dependency is currently broken and intentionally left broken until remote access is implemented.
* `/etc/electrs-mainnet/conf.d/interface.toml` contains all information required for accessing `electrs`, but you probably only need port.
* If you want to use `electrs` remotely you need some kind of tunnel - so far manual only, look at the port above
* the `electrs` needs to be fully synchronised before it even opens the rpc port (you can check it using `nmap localhost -p <rpc-port>` on the server)

### electrum

#### About

Electrum is a powerful Bitcoin wallet that has many interesting features, the most important being ability to use hardware wallets.
It needs a server to fetch data from.
The server (`electrs`) is provided in this repository.

#### Usage

* **Important: you need to have `desktop` component active in order to install `electrum`**
* You shouldn't notice a huge difference from running ordinary Electrum
* The only noteworthy change to the official app is that launching it from menu will make sure it's only connected to your own local full node.
* Please keep in mind you'll need to wait for `electrs` to sync before you can use Electrum

### lnd and lncli

#### About

`lnd` is a feature-full implementation of Lightning Network.
It can be controlled from other graphical apps or from command line using `lncli`.

#### Usage

* **Installing `lnd` automatically installs `lnd-unlocker`, which creates a wallet right after installation and stores the seed in `/var/lib/lnd-system-mainnet/.seed.txt`**
* The above behavior can be overwritten by `--no-install-recommends`, but **do not do it unless you prefer false sense of security. Without unlocker `lnd` will stay down after crash. If long enough others may steal your sats!**
* Check `thunderhub` and `ridetheln` packages for a nice graphical interface.
* Check `lndconnect` package to connect to LND with Zap.
* You can use `sudo` to run `lncli` or add yourself to group `lnd-system-mainnet`.
* If you want to grant some user readonly or invoice access, add them to group `lnd-system-mainnet-readonly` or `lnd-system-mainnet-invoice`
* A special package `lnd-genmacaroon` takes care of generating a special macaroon that is a union of readonly and invoice. It's stored at `/var/lib/lnd-system-mainnet/invoice/invoice+readonly.macaroon`. This is currently used by BTCPayServer.

### lndconnect

#### About

`lndconnect` is a helper tool to allow connecting from Zap or other compatible UI to your LND.
**Important: This package is temporary and will be eventually replaced with a graphical version!**

#### Usage

Just run `sudo lndconnect` to get the connection string.

You can create the QR code by installing `qrencode` and running `sudo lndconnect | qrencode -o lndconnect.png`

The package is currently Tor-only due to security and other technical reasons.

### nbxplorer

#### About

A minimalist UTXO tracker for HD Wallets. Used primarily with BTCPayServer.

#### Usage

You probably don't want to use `nbxplorer` directly but install BTCPayServer.
If you need to use it directly, you can find the port in `/etc/nbxplorer-mainnet/nbxplorer.conf`
and the cookie in `/var/lib/nbxplorer-mainnet/Main/.cookie`.

**Warning: this is not considered a public API and may change!**

### btcpayserver

#### About

BTCPayServer is a self-hosted server compatible with Bitpay API.

#### Usage

* When you install `btcpayserver` it automatically installs tooling to get onion domain
* You can get the host name using `sudo /usr/share/selfhost/lib/get_default_domain.sh && echo`
* **You must access `http://....onion/btcpay` right after installation and register an admin account!**
* Integrated with `selfhost` - please read the docs of `selfhost`.

Notable differences from the Docker deployment:

* No shitcoins (not that I'd hate them, I just don't have the time for them)
* Lightning setup is more secure (uses a specialized macaroon to prevent BTCPayServer from spending money)
* LND seed is not exposed to BTCPayServer, thus not visible in the UI.
* Lower attack surface (Docker not needed)
* "External services" not provided via BTCPayServer UI for security reasons. There will be a specialized UI for securely handling installed services.
* Some questionable packages are not available now (alpha stuff like transmuter or kitchen-sink like pihole)
* Some useful packages not packaged yet.

### thunderhub

#### About

ThunderHub is a powerful and beautiful web UI for LND.

#### Usage

* To open ThunderHub run `sudo thunderhub-open`
* If you use it on a remote node, the command above will print out the link that you need to copy into the browser
* Integrated with `selfhost` - please read the docs of `selfhost`.

### ridetheln

#### About

RTL (Ride The Lightning) is a multi-node Lightning web UI.

#### Usage

* Run `sudo /usr/share/selfhost/lib/get_default_domain.sh && echo -n '/rtl/?access-key=' && sudo cat /var/lib/ridetheln-system/sso/cookie` to get the link to RTL.
* Sorry, not a nice command, will be added in the future.
* Both mainnet and regtest LND use the same RTL!
* Integrated with `selfhost` - please read the docs of `selfhost`.

### btc-rpc-explorer

#### About

BTC RPC Explorer is a very powerful Bitcoin explorer that uses your own full node and doesn't require (but supports) additional indexing (beyond `txindex`).

#### Usage

* Run `sudo /usr/share/selfhost/lib/get_default_domain.sh && echo '/btc-rpc-explorer'` to get the link
* Run `sudo grep '^BTCEXP_BASIC_AUTH_PASSWORD' /etc/btc-rpc-explorer-mainnet/btc-rpc-explorer.conf | sed 's/^BTCEXP_BASIC_AUTH_PASSWORD=//'` to get the password
* Enter the password into the password field in the browser, username doesn't matter (can be empty)
* Integrated with `selfhost` - please read the docs of `selfhost`.

### selfhost

#### About

`selfhost` is a flexible set of tools used to automate hosting web applications on your own server with minimal effort.

#### Usage

* Each installed app that supports `selfhost` integrates with it out of the box.
* Tor onion domain is generated by default.
* Install `selfhost-clearnet` to activate clearnet domain **continue reading the docs!**
* Installation of `selfhost-clearnet` **requires interaction** because it asks for domain.
* **You must have a working domain pointing to your node for `selfhost-clearnet` to work!**
* `selfhost-clearnet-certbot` is installed by default and **needs a working e-mail address** for receiving **important security notifications**!
* `selfhost-clearnet-certbot` will create a TLS certificate for you so that HTTPS works.

### btc-transmuter

#### About

A self-hosted, modular IFTTT-inspired system for bitcoin services

#### Usage

**Warning: btc-transmuter is alpha and has some issues, make sure you read usage before using it.
You MUST open `/transmuter` immediately after installing and register a new user account!
Then go to server settings disable registration and hit Save.

Unless the situation improves this package will be replaced with something better in the future.**

* The most interesting use case is sending e-mails when an invoice is paid.
  Go to external services and configure BTCPayServer and SMTP, then open Presets
  and select the appropriate link.
  Fill the template and save.
* Pairing with BTCPayServer is clunky - you need to enter `yourdomain.com/btcpay` and hit Save.
  A pairing link will appear - click it to open BTCPayServer.
  Select the store you want to use and confirm.
  Go back to Transmuter and click Save again - it should finish pairing now.
* If you use GMail as SMTP provider you will need to use application-specific password if you use 2FA
  or enable "less secure" applications.
  IMAP has to be activated either way.

### remir

#### About

A simple server for controlling IR-enabled devices.

#### Usage

Your device MUST have a LIRC-capable IR transmitter!
I recommend using Raspberry Pi with `lirc_rpi` configured.
Just install the package and either pick a password or let it generate a random one.
The password will also be stored in /var/run/remir/password.
After you've configured LIRC, open your browser using selfhost domain, followed by
`remir` root path (default is `/remir`) followed by slash and the password.
