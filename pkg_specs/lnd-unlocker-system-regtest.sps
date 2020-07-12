name = "lnd-unlocker-system-regtest"
bin_package = "lnd-auto-unlock"
binary = "/usr/share/lnd/auto_unlock.sh"
user = { name = "lnd-system-regtest", group = true }
depends = ["lnd-system-regtest"]
summary = "Automatic unlocker for Lightning Network Daemon (regtest)"
service_type = "oneshot"
# We just need to simulate stateful behavior
exec_stop = "/bin/true"
binds_to = "lnd-system-regtest.service"
wanted_by = "lnd-system-regtest.service"
after = "lnd-system-regtest.service"
refuse_manual_stop = true
extra_service_config = """
Environment="BITCOIN_NETWORK=regtest"
RemainAfterExit=true
"""
