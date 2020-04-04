name = "selfhost"
version = "0.1.0"
summary = "Tooling for hosting web applications"
# The gateway implementation is separated out, but rigid now.
# We want to decouple it completely at some point, but that's not a priority right now.
depends = ["selfhost-nginx"]

[config."domains.conf"]
format = "yaml"
cat_dir = "domains"

[config."domains.conf".postprocess]
command = ["bash", "/usr/share/selfhost-nginx/generate_domains.sh"]

[[config."domains.conf".postprocess.generates]]
file = "/etc/nginx/sites-available/selfhost.conf"
internal = true

[[config."domains.conf".postprocess.generates]]
file = "/etc/nginx/sites-enabled/selfhost.conf"
internal = true

[config."apps.conf"]
format = "yaml"
cat_dir = "apps"

[config."apps.conf".postprocess]
command = ["bash", "/usr/share/selfhost-nginx/generate_apps.sh"]

[[config."apps.conf".postprocess.generates]]
file = "/etc/nginx/selfhost-subsites-available/apps.conf"
internal = true

[[config."apps.conf".postprocess.generates]]
file = "/etc/nginx/selfhost-subsites-enabled/apps.conf"
internal = true
