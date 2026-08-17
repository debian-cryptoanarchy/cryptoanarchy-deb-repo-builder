# Upgrading to Debian 12 - Bookworm

**Please follow these instructions carefully to ensure smooth upgrade! Failure to do so may result in CATASTROPHIC system breakage!**

All commands in this guide assume you're logged in as `root`. If not, log in as root or use `sudo` in front of each. If you haven't upgraded to Bullseye yet you MUST [do it separately](../bullseye.md), before upgrading to Bookworm.

Consider also reading the [Debian upgrade guide](https://www.debian.org/releases/bookworm/amd64/release-notes/ch-upgrading.en.html),
however you do not need to uninstall any CADR packages/sources as suggested in section 4.2 - direct upgrade is supported by CADR!

**Important note for experimental Nextcloud users:** Upgrading Nextcloud across multiple major versions is not officially supported by upstream. However, this doesn't mean it's technically impossible, just that they cannot guarantee correctness. Unfortunately, it's not possible for me to guarantee correctness either, however light testing was performed and the upgrade seems to work, so you may try it by explicitly opting into potentially dangerous operation - read below. **Make sure to have backups!!!**

## Preparation

0. Make sure you have enough space.
1. Run `apt update` and `apt dist-upgrade`, possibly also `apt autoremove --purge` and `apt clean`
2. If you use Nextcloud server, verify that nextcloud-server-system is at version 21.0.0-8.
   **Important - upgrading to bookworm from a lower version WILL CERTAINLY break your system!**
   This is a non-issue if you don't use Nextcloud.
3. A catastrophic failure is very unlikely but it's still recommended to backup the channels and stopping LND immediately afterwards by running `systemctl stop lnd-system-mainnet`
4. Edit `/etc/apt/sources.list` and all the files in `/etc/apt/sources.list.d` according to these rules:
    * Change any occurrence of `bullseye` to `bookworm`
    * Change `https://packages.microsoft.com/debian/11/prod bullseye` to `https://packages.microsoft.com/debian/12/prod bookworm` - note *also* the 11 to 12 change!
    * Change all the remaining instances of `bullseye` to `bookworm`. The vim command `:%s/bullseye/bookworm/` can be used.
    * If you see `non-free` component in the file and don't understand why it's there, change it to `non-free non-free-firmware` (so adding non-free-firware). Otherwise read the official release notes to understand the change.
5. Run `apt update`

**Warning: users of Debian delivered by third party providers (e.g. standalone Qubes VM) may need to do additional actions - please check the provider's documentation if this is your case!**

## Running upgrade

0. Run `apt install dpkg` - despite the word `install`, this will *upgrade* `dpkg` - verify that the version it was upgraded to is at least 1.21.23. Failing to do this will cause weird suspicious errors.
1. You may want to run `apt upgrade --without-new-pkgs` as suggested in the Debian guide but this is not required by CADR
2. Run `apt full-upgrade`. You may want to check for suspicious changes such as removing packages that should be installed, however this is unlikely to happen.
The process is interactive and you will be shown changelog (press `q` to quit it), asked about `glibc` upgrade (select yes) and about restarting of the services (yes is recommended).
This step takes around 30 minutes on usual hardware.

You may be asked about configuration changes.
If you changed a configuration file that is also changed by the upgrade you'll be asked what to do about it.
Keeping the file as-is (`N` option) is the safest but if you're unsure select diff to see the difference.
Just note that `sudo` configuration is one of the changed files so be careful to not lock yourself out!

## Finishing touches

If you've stopped LND you can start it now: `systemctl start lnd-system-mainnet`

During upgrade you'll be reminded to upgrade postgres cluster. Run these commands:

1. `pg_dropcluster --stop 15 main` - **WARNING: this command is dangerous! It's recommended to prevent it from being in history by putting a space in front of it.**
2. `pg_upgradecluster 13 main`
3. After verifying that everything works: `pg_dropcluster --stop 13 main`

You can also cleanup unneeded packages:

1. `apt autoremove --purge`
2. `apt clean`

Finally consider rebooting as you will get a new kernel. There's no annoying window forcing you to do so though. ;)
