name = "ridetheln"
architecture = "all"
summary = "A full function web browser app for LND and C-Lightning."
depends = ["nodejs (>= 8.0.0)"]
recommends = ["ridetheln-system"]
add_files = ["/usr/lib/ridetheln"]
import_files = [
	["../ridetheln/assets/ridetheln", "/usr/bin/ridetheln"],
	["../ridetheln/update_config.sh", "/usr/share/ridetheln/update_config.sh"],
	["../ridetheln/alloc_index.sh", "/usr/share/ridetheln/alloc_index.sh"],
	["../ridetheln/selfhost-dashboard/entry_points/open", "/usr/share/ridetheln/selfhost-dashboard/entry_points/open"]
]
long_doc = """RTL is a full function, device agnostic, web user interface to help manage
lightning node operations. RTL is available on LND and C-Lightning
implementations."""
