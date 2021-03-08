name = "nextcloud-server-system"
summary = "Automates deployment of Nextcloud server using selfhost"
architecture = "all"
recommends = ["selfhost (>= 0.1.6-2)", "selfhost (<< 0.2.0)"]
depends = ["default-selfhost-domain | selfhost-domain", "nextcloud-server (>= 20.0.4)", "php-fpm", "ruby-mustache", "php-pgsql"]
add_files = ["selfhost_tools/* /usr/share/nextcloud-server-system", "nextcloud-server-periodic.service /usr/lib/systemd/system", "nextcloud-server-periodic.timer /usr/lib/systemd/system"]
add_links = [ "/usr/share/nextcloud-server-system/main_icon.png /usr/share/selfhost-dashboard/apps/icons/nextcloud-system/entry_main.png" ]
extra_triggers = ["/etc/selfhost/domains"]

[databases.pgsql]
template = """
dbc_server="_DBC_DBSERVER_"
dbc_port="_DBC_DBPORT_"
dbc_dbname="_DBC_DBNAME_"
dbc_user="_DBC_DBUSER_"
dbc_password="_DBC_DBPASS_"
"""

[config."nextcloud.conf"]
format = "plain"

[config."nextcloud.conf".postprocess]
command = ["/usr/share/nextcloud-server-system/finalize_installation.sh"]

[config."nextcloud.conf".ivars.root_path]
type = "string"
default = "/nextcloud"
priority = "medium"
summary = "Web prefix of web path to Nextcloud server"

[config."../selfhost/apps/nextcloud-system.conf"]
format = "yaml"
external = true
with_header = true

[config."../selfhost/apps/nextcloud-system.conf".evars.nextcloud-server-system.root_path]
name = "root_path"

[config."../selfhost/apps/nextcloud-system.conf".hvars.include_custom]
type = "string"
constant = "nextcloud-server.conf"

[config."../selfhost/apps/nextcloud-system.conf".hvars.root_path_redirect_slash]
type = "bool"
constant = "true"

[config."../../etc/selfhost-dashboard/apps/nextcloud-system/meta.toml"]
format = "toml"
external = true

[config."../../etc/selfhost-dashboard/apps/nextcloud-system/meta.toml".hvars.user_friendly_name]
type = "string"
template = "Nextcloud"

[config."../../etc/selfhost-dashboard/apps/nextcloud-system/meta.toml".hvars.admin_only]
type = "bool"
constant = "false"

[config."../../etc/selfhost-dashboard/apps/nextcloud-system/meta.toml".hvars.entry_point]
type = "uint"
constant = "{ \\\"Static\\\" = { \\\"url\\\" = \\\"/\\\" } }"
