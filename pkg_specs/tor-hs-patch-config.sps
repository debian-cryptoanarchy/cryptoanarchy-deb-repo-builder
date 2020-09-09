name = "tor-hs-patch-config"
extends = "tor"
depends_on_extended = true
external = true
summary = "A patch to make adding hidden services easier"
add_files = [
	"defaults.patch /usr/share/tor-hs-patch-config",
	"apparmor.patch /usr/share/tor-hs-patch-config"
]
add_dirs = [
	"/etc/tor/torrc.d",
	"/etc/tor/hidden-services.d",
]

[patch_foreign]
"/usr/share/tor/tor-service-defaults-torrc" = "/usr/share/tor-hs-patch-config/defaults.patch"
"/etc/apparmor.d/local/system_tor" = "/usr/share/tor-hs-patch-config/apparmor.patch"
