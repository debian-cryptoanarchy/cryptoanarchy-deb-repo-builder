name = "ridetheln"
architecture = "all"
summary = "A full function web browser app for LND and C-Lightning."
depends = ["nodejs (>= 8.0.0)", "${shlibs:Depends} ${misc:Depends}"]
recommends = ["ridetheln-system"]
add_files = ["/usr/share/ridetheln", "/usr/bin/ridetheln"]
long_doc = """RTL is a full function, device agnostic, web user interface to help manage
lightning node operations. RTL is available on LND and C-Lightning
implementations."""
