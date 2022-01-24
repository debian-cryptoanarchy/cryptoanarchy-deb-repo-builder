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

## Project structure overview

This repository is the tooling for *building* the *debian* repository.
The whole process generally consists of these steps:

0. Download source code, signatures and other files required for building
1. Verify signatures
2. Copy additional files from this directory to the build directory
3. Run [`debcrafter`](https://github.com/Kixunil/debcrafter/) to generate the Debian packages
4. Build the package using `dpkg-buildpackage`

The code for executing these steps is in the `Makefile` and its includes.
Currently the download and copy step is defined in `build_rules` directory.
Inputs for `debcrafter` are in `pkg_specs` direcotry.
Additional files are in per-project directories (e.g. `bitcoin/`)

There is a plan to move files in `build_rules` and `pkg_specs` into package directories in the future, so don't get too attached to this.

### Build rules files

The files are written in Yaml because this is what `ruby-mustache` takes as an input.
They contain these important keys:

* `fingerprint` - PGP fingerprint of the project maintainer.
                  The signatures are verified against this.
                  In the future we'd like to support multisig.
* `unpack` or `clone_url` - depending on the download method, `clone_url` refers to git URL and `unpack` contains URL of an archive and related iformation
* `git_tag` (if git is used) - template for git tag that fills the current version
* `verify_tag` or `verify_commit` - which method of source code verification should be used.
* `shasums` - URL pointing to signed manifest file containing SHA256 sums, may contain `detached_sig` for URL of a detached signature.
* `build_system` - depends on used programming language. Buildsystems are defined in the `buildsystems` directory. Use `none` for pre-built binaries.
* `copy_assets` - list of files to copy from this repository to the build direcotry. Uses `from` and `to` keys.
* buildsystem-specific options, e.g. `cargo_args`

### Debcrafter files

There are two kinds of debcrafter files + changelog files in the directory.

* `.sss` - "smart source specification" - defines basics of the source package.
* `.sps` - "smart package specification" - defines how individual packages look and behave.
* `.changelog` - literally the Debian changelog format, it's just copied into output directory and also used to read version.

There are three kinds of `sps` files:

* Basic - most often contains just binaries or dumb data.
* Service - defines a service launched with the system (e.g. `bitcoind`) and the corresponding package.
            These are often parametrised over bitcoin network (`mainnet`, `regtest`)
* Configuration extensions - define packages that control configuration.
                             These are used for settings that need to be enforced by the depending packages.
			     The main idea is to avoid conflicting configuration and other issues.

The kind of sps package is inferred from content and can not be distinguished otherwise.
Basically, if the file contains service-related options it's a service package,
if it contains `architecture` key it's a basic package,
everything else is a configuration extension.

## Adding a new package

Although a new package can be added manually, this process can be simiplified using the **WIP** tool [cadr-guide](https://github.com/debian-cryptoanarchy/cadr-guide).
Newbies are encouraged to try it out before manual attempts.
