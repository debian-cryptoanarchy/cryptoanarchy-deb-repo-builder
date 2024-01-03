name = "selfhost"
architecture = "all"
summary = "Tooling for hosting web applications"
# The gateway implementation is separated out, but rigid now.
# We want to decouple it completely at some point, but that's not a priority right now.
depends = ["selfhost-nginx (>= 0.1.4)", "selfhost-nginx (<< 0.2.0)", "default-selfhost-domain (>= 1.0) | selfhost-domain (>= 1.0)", "default-selfhost-domain (<< 2.0) | selfhost-domain (<< 2.0)"]
import_files = [["../selfhost/lib/get_default_domain.sh", "/usr/share/selfhost/lib/get_default_domain.sh"]]

[config."domains.conf"]
format = "yaml"
cat_dir = "domains"

[config."domains.conf".postprocess]
command = ["bash", "/usr/share/selfhost-nginx/generate_config.sh", "domains"]

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
command = ["bash", "/usr/share/selfhost-nginx/generate_config.sh", "apps"]

[[config."apps.conf".postprocess.generates]]
dir = "/etc/nginx/selfhost-subsites-available"
internal = true

[[config."apps.conf".postprocess.generates]]
dir = "/etc/nginx/selfhost-subsites-enabled"
internal = true
