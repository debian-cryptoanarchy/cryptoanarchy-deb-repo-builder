name = "publish-bitcoin-whitepaper"
extends = "selfhost"
depends_on_extended = true
replaces = false
summary = "Publishes bitcoin whitepaper as /bitcoin.pdf"
import_files = [
	["../bitcoin-whitepaper/bitcoin.pdf", "/usr/share/publish-bitcoin-whitepaper/bitcoin.pdf"],
	["../bitcoin-whitepaper/publish-bitcoin-whitepaper.conf", "/usr/share/publish-bitcoin-whitepaper/publish-bitcoin-whitepaper.conf"],
]
add_links = ["/usr/share/publish-bitcoin-whitepaper/publish-bitcoin-whitepaper.conf /etc/nginx/selfhost-subsites-enabled/publish-bitcoin-whitepaper.conf"]

# Hack to write postprocess
[config."null"]
format = "plain"

[config."null".postprocess]
command = ["dpkg-trigger", "nginx-reload"]
