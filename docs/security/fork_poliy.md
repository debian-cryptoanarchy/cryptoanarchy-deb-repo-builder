# Policy on Bitcoin consensus forks

## About

This document describes the policy on upgrading `bitcoind` binary with consensus forking code.

**Important: this policy is young and may be refined!**
Feel free to submit your feedback.
Please come here again later to check if it's still the same.
Note: as predicted it was already updated to account for Speedy Trial. 

## General goals and rules

The goal of the policy of this repository is to minimize the risk by default while still allowing free choice.

As of today, the policy is this:

* No hard forks will update existing `bitcoind` binary unless they fix critical vulnerability (extremely improbable,
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
* No update will ever remove `bitcoind` or make it inoperable as such would endanger Lightning node(s). Additional
  effort to supply Lightning node(s) with transactions from competing chains will be seriously considered.
* Custom split protections may be implemented. These may include temporarily changing the configuration to require more
  confirmations unless the user explicitly turned off this protection.
* Custom alert system may be developed that will work together with the above and allow the user to take the risk.

## Policy specific to Taproot activation

While the above should give good overview, this clarifies what will be done in case of Taproot:

### Speedy Trial

* This repository will contain a widely-accepted version of Speedy Trial.
* If Speedy Trial succeeds, all future versions will have to be compatible with it (enforcing soft fork)
* If Speedy Trial fails, the original plan will be reconsidered
* Bumping min confirmations may be implemented but probably with a lower number (12 instead of 100).

### Original plan (BIP8)

* Unless there will be wide, strong opposition to `LOT=true`, **this repository will contain a client with `LOT=true` by default.**
  Rationale: `LOT=false` risks wiping the funds if there's a sufficient number of users running `LOT=true`.
  Besides, all known users of this repository prefer `LOT=true`.
  (Please report if you use this repository and prefer `false`!)
* Bumping min confirmations in `lnd` will be researched and carefully considered.
* Bumping confirmations in BTCPayServer is probably difficult and surprising.
  Attempt will be made to coordinate with BTCPayServer devs.
* The planned alert system will be prioritized in the upcoming few months.
  It will display one precautionary alert message on upgrade unless the upgrade is performed long after miner activation.
  Then a next one around timeout unless Taproot is active for a while already.
* Upgrading to `bitcoind` with Taproot support will have the highest priority (except critical security vulnerabilities),
  followed by updating all applications implementing split protections.
