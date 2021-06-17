name = "nextcloud-server-redis"
bin_package = "redis-server"
binary = "/usr/bin/redis-server"
bare_conf_param = true
positional_conf_param = true
runtime_dir = { mode = "750" }
user = { name = "nextcloud-server-system", group = true }
summary = "Redis integration for Nextcloud"
depends = ["nextcloud-server-system", "cadr-policy (>= 0.1.0)", "cadr-policy (<< 0.2.0)", "php-redis"]
add_files = ["setup_redis.sh usr/share/nextcloud-server-system"]
extra_service_config = """
Restart=always
"""

[config."redis.conf"]
format = "space_separated"
public = true

[config."redis.conf".hvars.port]
type = "uint"
constant = "0"

[config."redis.conf".hvars.unixsocket]
type = "path"
constant = "/var/run/nextcloud-server-redis/redis.sock"

[config."redis.conf".hvars.unixsocketperm]
type = "uint"
constant = "700"

[config."redis.conf".hvars.timeout]
type = "uint"
constant = "0"

[config."redis.conf".hvars.supervised]
type = "string"
constant = "systemd"

[config."redis.conf".hvars.daemonize]
type = "string"
constant = "no"

# TODO: make selectable
[config."redis.conf".hvars.loglevel]
type = "string"
constant = "notice"

[config."redis.conf".hvars.logfile]
type = "path"
constant = "/var/log/nextcloud-server-system/redis.log"

[config."redis.conf".hvars.databases]
type = "uint"
constant = "1"

[config."redis.conf".hvars.always-show-logo]
type = "string"
constant = "no"

[config."redis.conf".hvars.dir]
type = "path"
file_type = "dir"
create = { mode = 750, owner = "$service", group = "$service" }
constant = "/var/lib/nextcloud-server-system/redis"

[[plug]]
run_as_user = "root"
register_cmd = ["/usr/share/cadr-policy/disable_service", "redis-server", "redis-server", "nextcloud-server-redis"]
unregister_cmd = ["/usr/share/cadr-policy/enable_service", "redis-server", "redis-server", "nextcloud-server-redis"]

[[plug]]
run_as_user = "root"
register_cmd = ["/usr/share/nextcloud-server-system/setup_redis.sh"]
unregister_cmd = ["true"]
