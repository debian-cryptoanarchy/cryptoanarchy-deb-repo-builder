name = "lnd-unlocker-system-@variant"
bin_package = "lnd-auto-unlock"
binary = "/usr/share/lnd-auto-unlock/auto_unlock.sh"
user = { name = "lnd-system-{variant}", group = true }
depends = ["lnd-system-{variant} (>= 0.13.1)"]
summary = "Automatic unlocker for Lightning Network Daemon ({variant})"
service_type = "oneshot"
# We just need to simulate stateful behavior
exec_stop = "/bin/true"
binds_to = "lnd-system-{variant}.service"
wanted_by = "lnd-system-{variant}.service"
after = "lnd-system-{variant}.service"
refuse_manual_stop = true
extra_service_config = """
Environment="BITCOIN_NETWORK={variant}"
RemainAfterExit=true
"""

[[plug]]
run_as_user = "root"
register_cmd = ["/usr/share/lnd-auto-unlock/set.sh", "{variant}"]
unregister_cmd = ["rm", "-f", "/var/lib/lnd-system-{variant}/.auto_unlock"]
