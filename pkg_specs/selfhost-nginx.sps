name = "selfhost-nginx"
architecture = "all"
summary = "Tooling for hosting web applications using nginx"
depends = ["nginx", "ruby-mustache", "bash", "python3"]
conflicts = ["selfhost-domain (<< 1.1)"]
import_files = [
	["../selfhost/nginx/config_top_template.mustache", "/usr/share/selfhost-nginx/config_top_template.mustache"],
	["../selfhost/nginx/config_sub_template.mustache", "/usr/share/selfhost-nginx/config_sub_template.mustache"],
	["../selfhost/nginx/generate_config.sh", "/usr/share/selfhost-nginx/generate_config.sh"],
]
