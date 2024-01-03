name = "tor-hs-patch-config"
extends = "tor"
depends_on_extended = true
depends = ["tor (>= 0.3.1.1)"]
external = true
summary = "A patch to make adding hidden services easier"
import_files = [
	["../tor-extras/assets/defaults.patch", "/usr/share/tor-hs-patch-config/defaults.patch"],
	["../tor-extras/assets/apparmor.patch", "/usr/share/tor-hs-patch-config/apparmor.patch"]
]
add_dirs = [
	"/etc/tor/torrc.d",
	"/etc/tor/hidden-services.d",
]

[patch_foreign]
"/usr/share/tor/tor-service-defaults-torrc" = "/usr/share/tor-hs-patch-config/defaults.patch"
"/etc/apparmor.d/local/system_tor" = "/usr/share/tor-hs-patch-config/apparmor.patch"
