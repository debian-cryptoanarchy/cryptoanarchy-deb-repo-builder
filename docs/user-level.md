# User-level documentation of Cryptoanarchy Debian Repository

## What's the point

If you use any operating system, there are many programs called "services" running in the background handling various tasks for you. Whether it's drivers, file indexers, music players... It's almost certain you don't even know what many of them do and how they got into the system. In general all OSes have their ways to get those important services to run on your computer. Debian uses its own "package manager" that can automatically figure out which services you need and install them for you based on what applications you use.

There are several services that tend to run on Debian or derived OSes. Some examples:

* systemd
* Network Manager
* pulseaudio
* avahi

You most likely didn't even think about them, they are there because the system knows they are needed.

I believe that this is how Bitcoin software should behave too. You should not have to manually install and configure everything. While possible, educating and empowering, it comes with great costs:

* Not everyone has confidence or time to do that
* Security risks stemming from misconfiguration
* Security risks stemming from failure to verify the software properly (tedious task that package managers can handle too)
* It gets boring once you do it for a ~third time

It was not previously possible to install Bitcoin software as automatically as e.g. pulseaudio because nobody created the package files needed for it to work. This project changes that issue and provides set of great, interconnected packages that configure themselves automatically!

Yes, installing any Bitcoin/freedom-related application is now going to be as easy as installing VLC. It'll be possible to use GUI or simple `apt` command.

## What you need to know before installing anything from this repository

(TL;DR below)

The most important information is that **the project is still work in progress**! While the user-level documentation is written for those who don't want to care about the details, it does **not** imply you don't need admin skills! Quite the opposite. You should have the admin skills, at least the ability to use terminal and a GitHub account for communicating issues!

With that out of the way, let's talk about the general structure first. There are many packages that are connected in various ways. They the have proper dependency relationships declared that make sure you don't install a package without an important part. So for the most part, you can just blindly install packages. There are a few important things you need to have in mind, though!

* Only Debian 10 is currently officially supported. Ubuntu and derivatives should work, but we can't be sure.
* Beware: as explained above, bitcoin and all related services will run automatically right after boot until you shutdown the computer!
* Some packages require bitcoin **without pruning** to be configured. And they will do it automatically. That means, if you have less than 350 GB of free space, you should be very careful about what you install! Basically, the only (somewhat) useful packages that you can install now are `bitcoin-rpc-proxy`, `nbxplorer`, `btcpayserver`, `selfhost*`, `tor-hs-patch-config`
* The data does **not** go to your home directory, but under `/var/lib` if you have partitioned your disks to have big home partition and small system partition, you will have to set a different path **using debconf** - read below.
* Contrary to the convention, all the configuration files are auto-generated and **must not** be edited! If you need to tune something, the best place to do that is using debconf. The second best place is filing a request for the setting on GitHub, if it isn't in debconf yet. If you can't wait for the implementation, place it into an appropriate `conf.d` directory and re-run debconf. However continue reading!
* Any change to configuration requires running `dpkg-reconfigure`
* Some configuration is special in being controlled by certain packages being or not being installed. The most important case is configuration of pruning/non-pruning/txindex of bitcoind. If you want to change the setting, you must install the appropriate package: `bitcoin-pruned-mainnet`, `bitcoin-fullchain-mainnet`, `bitcoin-txindex-mainnet`. Naturally, **only one of them can be installed at the same time**. Further **some other packages, like `electrs` require specific package to be installed!** Note however, that `txindex` implies `fullchain`, so having it installed is fine for `electrs` and such. Obviously, `pruned` can't be installed with `electrs`. While there are ways to hack this, just don't. You will run into a lot of trouble. The point of this repository is to (hoepfuly) never break.
* When you change the configuration of paths, they don't get moved automatically! This will be fixed eventually, just be careful around that for now.
* Many dependencies are specified using `Recommends`, which means installing stuff with `--no-install-recommends` will work, but won't be very useful.
* Lot of stuff here is intended for servers. While it can be used on desktop and the goal is to make it useful there eventually, it will take many months to get there.
* The server stuff is still considered advanced topic - read (the end of) the admin docs!
* `btcpayserver` and `ridetheln` (a better name for RTL, AKA Ride The Lightning) use a custom system of integration into `nginx` in order to get an onion domain, or even a clearnet domain with HTTPS certificate automatically. This is really great for user experience, but may be surprising to people who don't read the docs!
* If you want a clearnet domain, install `selfhost-clearnet` package. This will skip `clearnet-onion` unless you install both, of course. This operation can **not** be performed non-interactively, without preseting debconf!

If all that seems too long to you, here's a short version:

* **Keep in mind the project is still experimental**
* **LND seed is in /var/lib/lnd-system-mainnet/.seed.txt**
* Make sure you have at least 350 GB of free space
* Do **not** run `apt` with any funny switches
* Do **not** attempt to configure anything - it will just work
* Do **not** touch any configuration
* Do understand that bitcoind and other services will run automatically
* Read (the end of) the admin docs to understand server software (btcpayserver, ridetheln)
* When in doubt, ask on GitHub

Happy bitcoining!
