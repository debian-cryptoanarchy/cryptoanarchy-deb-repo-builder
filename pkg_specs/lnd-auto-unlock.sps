name = "lnd-auto-unlock"
architecture = "all"
summary = "Auto init/unlock script for LND"
depends = ["bash", "wget", "jq"]
add_files = ["auto_unlock.sh /usr/share/lnd"]
