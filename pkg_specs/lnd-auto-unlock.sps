name = "lnd-auto-unlock"
architecture = "all"
summary = "Auto init/unlock script for LND"
depends = ["bash", "wget", "jq"]
import_files = [
	["../lnd/auto_unlock.sh", "/usr/share/lnd-auto-unlock/auto_unlock.sh"],
	["../lnd/auto_unlock_common.sh", "/usr/share/lnd-auto-unlock/common.sh"],
	["../lnd/auto_unlock_set.sh", "/usr/share/lnd-auto-unlock/set.sh"],
	["../lnd/static_password", "/usr/share/lnd-auto-unlock/static_password"]
]
