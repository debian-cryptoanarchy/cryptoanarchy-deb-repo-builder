# Upgrading to Debian 11 - Bullseye

**Please follow these instructions carefully to ensure smooth upgrade!**

All commands in this guide assume you're logged in as `root`. If not, log in as root or use `sudo` in front of each.

Consider also reading the [Debian upgrade guide](https://www.debian.org/releases/bullseye/amd64/release-notes/ch-upgrading.en.html),
however you do not need to uninstall any CADR packages/sources as suggested in section 4.2 - direct upgrade is supported by CADR!

## Preparation

0. Make sure you have enough space.
1. Run `apt update` and `apt dist-upgrade`, possibly also `apt autoremove --purge` and `apt clean`
2. A catastrophic failure is very unlikely but it's still recommended to backup the channels and stopping LND immediately afterwards by running `systemctl stop lnd-system-mainnet`
3. Edit `/etc/apt/sources.list` and all the files in `/etc/apt/sources.list.d` according to these rules:
    * Change `buster/updates` to `bullseye-security`
    * Change `https://packages.microsoft.com/debian/10/prod buster` to `https://packages.microsoft.com/debian/11/prod bullseye` - note *also* the 10 to 11 change!
    * Change all the remaining instances of `buster` to `bullseye`. The vim command `:%s/buster/bullseye/` can be used.
4. Run `apt update`

## Running upgrade

Run `apt dist-upgrade`. You may want to check for suspicious changes such as removing packages that should be installed, however this is unlikely to happen.
The process is interactive and you will be shown changelog (press `q` to quit it), asked about `glibc` upgrade (select yes) and about restarting of the services (yes is recommended).
This step takes around 30 minutes on usual hardware.

You may be asked about configuration changes.
If you changed a configuration file that is also changed by the upgrade you'll be asked what to do about it.
Keeping the file as-is (`N` option) is the safest but if you're unsure select diff to see the difference.
Just note that `sudo` configuration is one of the changed files so be careful to not lock yourself out!

## Finishing touches

If you've stopped LND you can start it now: `systemctl start lnd-system-mainnet`

During upgrade you'll be reminded to upgrade postgres cluster. Run these commands:

1. `pg_dropcluster --stop 13 main` - **WARNING: this command is dangerous! It's recommended to prevent it from being in history by putting a space in front of it.**
2. `pg_upgradecluster 11 main`
3. After verifying that everything works: `pg_dropcluster --stop 11 main`

You can also cleanup unneeded packages:

1. `apt autoremove --purge`
2. `apt clean`

Finally consider rebooting as you will get a new kernel. There's no annoying window forcing you to do so though. ;)

