name = "selfhost-onion"
version = "0.1.0"
summary = "Tooling for hosting web applications over onion domain"
extends = "selfhost"
depends = ["tor-hs-patch-config", "bash"]

[config."domains/onion.conf"]
format = "yaml"
with_header = true

[config."domains/onion.conf".hvars.domain]
type = "string"
script = "bash /usr/share/selfhost-onion/onion_domain.sh"
