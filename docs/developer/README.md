# Development documentation

This directory documents how to develop **this repository**.
For information how to develop applications that integrate into this repository easily,
use time machine and read it in the future.

**If you're not a developer, this directory is useless to you.**

## Building

The only officially supported OS for building and running is currently **Debian 10 (Buster)**!
Contributions to test and fix **running** of this repository on other Debian-based systems welcome!

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

