name = "selfhost-onion"
summary = "Tooling for hosting web applications over onion domain"
extends = "selfhost"
depends = ["tor-hs-patch-config", "bash"]
provides = ["default-selfhost-domain (= 1.1)", "selfhost-domain (= 1.1)"]

add_files = [
	"onion/onion_domain.sh /usr/share/selfhost-onion",
	"onion/hidden_service.conf /usr/share/selfhost-onion",
	"onion/advertise_onion.sh /usr/share/selfhost-onion",
]

[config."domains/onion.conf"]
format = "yaml"
with_header = true

[config."domains/onion.conf".hvars.domain]
type = "string"
script = "bash /usr/share/selfhost-onion/onion_domain.sh"

[config."domains/onion.conf".hvars.is_onion]
type = "bool"
constant = "true"

[config."domains/onion.conf".postprocess]
command = ["bash", "/usr/share/selfhost-onion/advertise_onion.sh"]

[[config."domains/onion.conf".postprocess.generates]]
file = "/etc/nginx/selfhost-clearnet-conf.d/onion_location.conf"
internal = false

[[config."domains/onion.conf".postprocess.generates]]
file = "/etc/nginx/selfhost-clearnet-conf.d/onion_location.conf.tmp"
internal = true
