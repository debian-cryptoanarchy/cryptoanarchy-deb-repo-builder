name = "lnd-genmacaroon"
architecture = "all"
summary = "Creates additional LND macaroons"
depends = ["lncli", "bash"]
import_files = [["../lnd/gen_macaroons.sh", "/usr/share/lnd/gen_macaroons.sh"]]
