name = "lnd-genmacaroon"
architecture = "all"
summary = "Creates additional LND macaroons"
depends = ["lncli", "bash", "wget", "jq"]
add_files = ["gen_macaroons.sh /usr/share/lnd"]
