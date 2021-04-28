---
name: Bug report
about: Generic bugs
title: 'Bug:'
labels: bug
assignees: ''

---

<!-- IMPORTANT: Solving your problem will take longer if you do not fill this template properly! -->

**Have you read the documentation?**
Yes. (If no, please go check if this is a documented property.)

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Install packages: `a`, `b`, `c`
2. Configure package `a`
3. Perform X
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**System**
OS, if anything else than Debian Buster:
Installed packages from this repository and their versions:
Is apparmor enabled?

**Non-default configuration settings**
Please paste your non-default debconf configuration here. Also paste your custom configuration files if any.

**Logs of affected package(s)**
Please paste the log if installation failed
Please run `journalctl -u AFFECTED_PACKAGE` as root if a service crashed, e.g. `sudo journalctl btcpayserver-system-mainnet`
