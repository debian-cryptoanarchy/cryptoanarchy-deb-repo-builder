name = "ridetheln"
architecture = "all"
summary = "A full function web browser app for LND and C-Lightning."
depends = ["nodejs (>= 8.0.0)", "${shlibs:Depends} ${misc:Depends}"]
recommends = ["ridetheln-system"]
add_files = [
	"/usr/lib/ridetheln",
	"ridetheln /usr/bin/",
	"update_config.sh /usr/share/ridetheln",
	"alloc_index.sh /usr/share/ridetheln"
]
long_doc = """RTL is a full function, device agnostic, web user interface to help manage
lightning node operations. RTL is available on LND and C-Lightning
implementations."""
