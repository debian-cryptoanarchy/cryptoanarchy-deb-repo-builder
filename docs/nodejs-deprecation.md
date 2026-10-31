# Deprecation of NodeJS-based applications

The NodeJS applications are a constant source of upgrade problems, CI unreliability and other issues.
As such they are as of 31 October 2026 **deprecated**.
I will attempt to maintain them for a while and eventually drop the support.
The exact date is currently undecided but I will do my best to provide alternatives before I drop these.

The list of problems of NodeJS applications that I came across:

* Extremely frequent dependency problems (AKA dependency hell).
  Despite lock files, the builds constantly mysteriously break and require manual intervention.
  The amount of time spent on them is maybe 10x of other applications.
* Lack of reproducible builds - it is not possible to make sure that build doesn't break.
  You can't even do the basic thing: download everything separately and run the build in an offline machine.
  This causes CI to break even when unrelated applications are updated.
  In addition, auditing is harder and backporting fixes (including security fixes) might be prevented.
* These projects contain a ton of tiny files causing installation, upgrades... and building to be extermely slow.
  (And they say that Rust building is slow, LOL.)
  This makes maintenance hard because any problem may trigger full rebuild and retest which takes a very long time.
* Trouble linking to system libraries or use system dependencies.
  Many packages just YOLO vendor their libraries with latest version making it difficult to use on stable operating systems.
  While static linking solves it, it causes other problems, including prolonged compilation time.
* Cross compilation is basically impossible because NodeJS doesn't distinguish between host and target dependencies.
  This is a significant reason why Raspberry Pis weren't supported by this project for a long time.
* JavaScript is just a terrible programming language with track record of causing tons of security vulnerabilities or other bugs.
  It's extremely bloated, hard to review, hard to audit.
  While it's possible to write TypeScript instead, that still depends on the legacy wobbly ecosystem.
* NodeJS appears to attract people who don't care about security or are generally not well-experienced.
  This is not a jab at genuine newbies who are learning (but really, if you're one, consider trying something else) or true experts in JS.
  It's just that in my experince, this is the statistic.

These are a constant source of mental drain for me, demotivate me from working on the project and make it harder to upgrade across Debian versions, causing the project to lag behind.
(Though, they are *not* the *only* reason for this.)

**This does NOT mean that JavaScript in general is deprecated - BTCPayServer and similar projects will continue to be supported.**

## What to do if you're affected

If you're a user or a developer of any of these I suggest taking one of these steps:

* Fix the NPM ecosystem to not be that horrible. This is likely the hardest option.
* Rewrite those applications to a [more reasonable programming language](https://rust-lang.org) or technology stack.
* Recommend new alternatives to me.
* Make an "add-on repo" and maintain them there.
  You can make it compatible with this one so you will only have to maintain those applications and not others.
  I'm open to cooperate on API stability.
* Help me write new applications that will replace the existing ones.
* Pay me a lot of money to continue maintaining them.
  I'm not promising anything but you can try asking.
