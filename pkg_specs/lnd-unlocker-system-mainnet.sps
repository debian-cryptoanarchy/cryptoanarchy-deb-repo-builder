name = "lnd-unlocker-system-mainnet"
bin_package = "lnd-auto-unlock"
binary = "/usr/share/lnd/auto_unlock.sh"
user = { name = "lnd-system-mainnet", group = true }
depends = ["lnd-system-mainnet"]
summary = "Automatic unlocker for Lightning Network Daemon (mainnet)"
service_type = "oneshot"
# We just need to simulate stateful behavior
exec_stop = "/bin/true"
binds_to = "lnd-system-mainnet"
wanted_by = "lnd-system-mainnet.service"
after = "lnd-system-mainnet"
refuse_manual_stop = true
extra_service_config = """
Environment="BITCOIN_NETWORK=mainnet"
"""
