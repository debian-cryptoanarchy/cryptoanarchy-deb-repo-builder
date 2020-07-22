name = "lnd-genmacaroon-system-mainnet"
bin_package = "lnd-genmacaroon"
binary = "/usr/share/lnd/gen_macaroons.sh"
user = { name = "lnd-system-mainnet", group = true }
depends = ["lnd-system-mainnet", "lncli"]
summary = "Generates additional LND macaroons (mainnet)"
service_type = "oneshot"
# We just need to simulate stateful behavior
exec_stop = "/bin/true"
binds_to = "lnd-system-mainnet.service"
part_of = "lnd-system-mainnet.service"
wanted_by = "lnd-system-mainnet.service"
after = "lnd-system-mainnet.service lnd-unlocker-system-mainnet.service"
refuse_manual_stop = true
extra_service_config = """
Environment="BITCOIN_NETWORK=mainnet"
RemainAfterExit=true
"""
