name = "lnd-genmacaroon-system-@variant"
bin_package = "lnd-genmacaroon"
binary = "/usr/share/lnd/gen_macaroons.sh"
user = { name = "lnd-system-{variant}", group = true }
depends = ["lnd-system-{variant}", "lncli"]
summary = "Generates additional LND macaroons ({variant})"
service_type = "oneshot"
# We just need to simulate stateful behavior
exec_stop = "/bin/true"
binds_to = "lnd-system-{variant}.service"
part_of = "lnd-system-{variant}.service"
wanted_by = "lnd-system-{variant}.service"
after = "lnd-system-{variant}.service lnd-unlocker-system-{variant}.service"
refuse_manual_stop = true
extra_service_config = """
Environment="BITCOIN_NETWORK={variant}"
RemainAfterExit=true
"""
