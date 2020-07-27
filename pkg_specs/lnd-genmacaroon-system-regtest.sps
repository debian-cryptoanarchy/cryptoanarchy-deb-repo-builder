name = "lnd-genmacaroon-system-regtest"
bin_package = "lnd-genmacaroon"
binary = "/usr/share/lnd/gen_macaroons.sh"
user = { name = "lnd-system-regtest", group = true }
depends = ["lnd-system-regtest", "lncli"]
summary = "Generates additional LND macaroons (regtest)"
service_type = "oneshot"
# We just need to simulate stateful behavior
exec_stop = "/bin/true"
binds_to = "lnd-system-regtest.service"
part_of = "lnd-system-regtest.service"
wanted_by = "lnd-system-regtest.service"
after = "lnd-system-regtest.service lnd-unlocker-system-regtest.service"
refuse_manual_stop = true
extra_service_config = """
Environment="BITCOIN_NETWORK=regtest"
RemainAfterExit=true
"""
