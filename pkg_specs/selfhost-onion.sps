name = "selfhost-onion"
architecture = "all"
version = "0.1.0"
summary = "Tooling for hosting web applications over onion domain"
extends = "selfhost"
depends = ["tor-hs-patch-config", "bash"]
provides = ["default-selfhost-domain (= 1.0)", "selfhost-domain (= 1.0)"]

add_files = [
	"onion/onion_domain.sh /usr/share/selfhost-onion",
	"onion/hidden_service.conf /usr/share/selfhost-onion",
]

[config."domains/onion.conf"]
format = "yaml"
with_header = true

[config."domains/onion.conf".hvars.domain]
type = "string"
script = "bash /usr/share/selfhost-onion/onion_domain.sh"
