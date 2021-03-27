# Setting up the system on dedicated hardware

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
