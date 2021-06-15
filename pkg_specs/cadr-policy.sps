name = "cadr-policy"
architecture = "all"
summary = "System-wide policies used in Cryptoanarchy Debian Repository"
add_files = ["disable_service usr/share/cadr-policy", "enable_service usr/share/cadr-policy"]

[config."policy.conf"]
format = "plain"
public = true

[config."policy.conf".ivars.disable_unneeded_services]
type = "bool"
priority = "medium"
summary = "Should services not needed by CADR be disabled?"
default = "false"
