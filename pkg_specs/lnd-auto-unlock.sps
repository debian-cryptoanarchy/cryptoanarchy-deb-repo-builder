name = "lnd-auto-unlock"
architecture = "all"
summary = "Auto init/unlock script for LND"
depends = ["bash", "wget", "jq"]
add_files = ["auto_unlock/auto_unlock.sh /usr/share/lnd-auto-unlock", "auto_unlock/common.sh /usr/share/lnd-auto-unlock", "auto_unlock/set.sh /usr/share/lnd-auto-unlock", "auto_unlock/static_password /usr/share/lnd-auto-unlock"]
