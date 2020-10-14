name = "selfhost-dashboard"
summary = "Service package for selfhost-dashboard-bin"
bin_package = "selfhost-dashboard-bin"
binary = "/usr/bin/selfhost-dashboard"
conf_param = "--conf"
user = { name = "root" }
recommends = ["selfhost"]
extra_service_config = """
Restart=always
"""

[databases.pgsql]
template = """
pg_uri = "postgresql://_DBC_DBUSER_:_DBC_DBPASS_@_DBC_DBSERVER_:_DBC_DBPORT_/_DBC_DBNAME_"
"""

[config."interface.conf"]
format = "toml"

[config."interface.conf".ivars.root_path]
type = "string"
default = "/dashboard"
priority = "medium"
summary = "Web prefix of web path to selfhost-dashboard"

[config."interface.conf".ivars.bind_port]
type = "bind_port"
default = "9009"
priority = "medium"
summary = "Port for selfhost-dashboard to listen on"

[config."../selfhost/apps/selfhost-dashboard.conf"]
format = "yaml"
external = true
with_header = true

[config."../selfhost/apps/selfhost-dashboard.conf".evars.selfhost-dashboard.root_path]
name = "root_path"

[config."../selfhost/apps/selfhost-dashboard.conf".evars.selfhost-dashboard.bind_port]
name = "port"
