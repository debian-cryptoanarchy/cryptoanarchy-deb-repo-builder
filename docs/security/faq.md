# Security FAQ

## Is this project 100% secure?

No project is 100% secure.

## How much work went into securing this project?

A lot. Fundamental protections like isolation, principle of least privilege etc are followed.
In addition, packages added were reviewed to various degree, weaknesses reported and patched/taken into account.
No package was added without research and addressing serious security concerns.

For instance, RTL requires nodes to have unique indexes.
To prevent duplicates, a very reliable script was written that performs all relevant operations atomically.
Thus RTL indexes can not be duplicated even in case of power failure at any moment (assuming reliable `mv` and `fsync`).

## Which security techniques does this project use?

* Isolation
* Principle of least privilege
* Automation that prevents security-related mistakes
* Declarative programming with secure defaults (security is always opt-out, never opt-in)
* Code signing and verification
* Build in isolated ennvironment
* Determministic builds

## Which security features are rare or unique to this project?

**Important: the following is based on possibly limited information. If you know of a similar project with a security feature
mentioned here that's not attributed, please report.**

* This is the only project with a clear policy on forks.
* To my knowledge this project is the only one that uses `btc-rpc-proxy` to protect `bitcoind` out-of-the-box.
* This project was the first one to implement any kind of RPC filtering for `bitcoind`, long before it was available in `bitcoind` itself.
  This was later implemented in `nix-bitcoin`, which is the only other project that does this.
* This project was the first to implement a special macaroon that doesn't allow BTCPayServer to steal sats from LND.
  This was later copied by `nix-bitcoin` and it's the only other project that does this.
  Note that this is meant as a compliment to `nix-bitcoin` - copying important security features is a very good thing!
* This project implements SSO for several applications.
  The only other known project that does this is BTCPayServer-docker.
  The application handling authentication is intentionally much, much simpler than BTCPayServer, thus the attack surface is lower.
* This project sandboxes cookies of different apps to avoid them being passed between each-other.
  There's no other known project that does this.
* The keys of foreign developers are verified using memory-safe GPG implementation [`sqck`](https://github.com/Kixunil/sqck).
  No other known project uses `sqck`.
* All official builds are performed in a dedicated Qubes VM.
  No other known project does this.
* Perhaps except `nix-bitcoin`, no other project attempts deterministic builds.
  (Only ThunderHub is undeterministic here.)
* The only other known project that uses declarative approach is `nix-bitcoin`.

## Is it a good idea to put my lifesavings into this node?

No.

## Why doesn't this project use Docker?

Docker was **not** designed as a security mechanism and shouldn't be used as such.
There were actually numerous cases of escaping from Docker containers.
The Docker daemon adds its own attack surface.

That being said, Docker is just a collection of several mechanisms, some of which may be beneficial for security.
This project already uses some of them and maybe it will use more in the future (needs to be weighted against disadvantages).

## Does this project use virtual machines?

No, while VMs are a great technology when used properly, such as in the case of Qubes OS, they are heavy.
It could have negative effect of discouraging users from using it and leaving them with much worse options.
Finding a sweet spot can be more valuable.

This doesn't mean that VMs will **not** be researched in the future as an optional mechanism.
It's definitely considered a wishlist item.

## So how does this project isolate services?

Using different (system) users.
One for each service, except where it makes zero sense.

## Aren't users unsecure? What are the limitation of this design?

There doesn't seem to be any significant issue with using users as an isolation mechanism.
Android uses this same mechanism and there was no (valid) criticism of such approach.
(There were other issues unrelated to this particular mechanism.)

Where users probably get bad reputation is from poorly configured systems that have ridiculous errors like leaving bad permissions on a file.
Another good criticism is bulky privileged APIs exposed to unprivileged processes.
Such is the case of recent `sudo` vulnerability.

This project mitigates these issues by:

* Automating creation of filesystem items and setting proper permissions by default. This removes the possibility of mistakes.
* Not depending on bulky APIs and not installing them by default.
* Using "no new privileges" options which would prevent services from exploiting `sudo` vulnerability.

There's one known issue: possible race conditions when TCP servers are restarted.
This isn't trivial to exploit.
Remember, it **still** requires discovering a zero day vulnerability in one of the existing packages!
Fixing this is planned to be done soon and by using Unix sockets.

## How do I know the software I download is not malware?

The only 100% sure way is to review the project and all its dependencies and building on your own.

If you decide to trust me, then you only need to know my public key fingerprint.
You can obtain it by cross-referencing several sources ([I'm on Keybase](https://keybase.io/kixunil)) or in person in some cases.
`apt` already performs signature validation on all installed packages so that part is secure.
I myself verify signatures of all packages using a script to avoid mistakes and build the packages in a dedicated Qubes VM.

## Why is LND unlocker recommended? Isn't it dangerous?

On the contrary, not using unlocker is more dangerous.
This was discussed at length in [LND issue](https://github.com/lightningnetwork/lnd/issues/899), opened by widely-recognized security professional Peter Todd.
The gist of it is that it's extremely unlikely for an attacker to gain access to the LND database without also gaining access to other sensitive information.

If you don't use unlocker, you risk LND being down for too long and your peer stealing your sats.
LND being down is much more likely to happen.

The developers of LND themselves agreed recently that allowing empty passwords makes sense.
Read the issue for in-depth explanation.

## There are so many apps! Don't they increase attack surface?

They do if you install all of them.
The point of the project is that you only install what you require.
If you don't trust some app and don't install it, the attack surface of it is zero.

## I ran systemd-analyze security and there's a bunch of services with bad reports!

The short answer is that `systemd-analyze security` is a huge crap.
This is even admitted in the manual although not this honestly.

The specific objections to it:

* Some security options imply others are not needed.
  As an example, if the process is not `root` and can not become `root`, it's impossible for it to load kernel modules.
  Yet, `systemd-analyze security` reports that it is possible and assings it security score.
  Similar thing applies to other flags.
* Some security options have zero real effect on security.
  The worst example is restriction by IP address.
  IP addresses can be spoofed by trained monkeys, so implementing restrictions based on them is just a waste of time and introduces unneeded complexity.
* Some options, especially `PrivateNetwork` are assigned high risk but they destroy fundamental features of a service.
  `bitcoind` without network access is completely useless.

Yes, having some kind of ordering to help decide on priority of security review would be useful, especially regarding the last point.
Sadly, this tool doesn't even order its output
and tries to emotionally manipulate people into setting ridiculous options,
wasting time on non-issues, writing explanations like this one, or worst, distrusting something that's actually pretty secure.

This doesn't intend to imply that all relevenat options are tuned perfectly.
If you know of a reasonable improvement, please report!
Using `systemd-analyze security` is just useless because of lot of noise.

## Why is LND seed stored in plaintext?

The same reason why there's unlocker.
The seed is stored in a protected file in private directory.
If an attacker can obtain the seed, he can obtain the admin macaroon and and tls key.
These files can not be encrypted as it'd make LND unusable.

If you're concerned about people with physical access stealing your node and sats, just encrypt the whole OS.

## Are there automated (channel) backups?

Not yet, they are planned and considered high priority.

## How are Bitcoin forks handled?

Please read the documentation in the top-level README.

## I can't use this project for some reason, would you recommend something else that is very secure?

`nix-bitcoin` and Nodl should be good alternatives if security is important for you.

## What are the known things that could be improved?

* Building each package in a single VM.
  Note that this is only helpful if Debian build tools can not be compromised by bad inputs.
  This was not verified and probably isn't the case, so that's why it was put off for now.
* `thunderhub` could be built deterministically.
  This may be resolved in Debian 11, which contains newer NPM, which should make it possible.
  (Not tested.)
* It'd be great if this received review from independent developers.
* Automated backups could be added - this is high priority issue that should be solved in upcoming months. (#53)

## Is there something else I should know?

Be responsible.
No need to shit your pants, though.
