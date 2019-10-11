# TODO: sign and verify sources

btc-rpc-proxy:
	git clone https://github.com/Kixunil/btc-rpc-proxy

btc-rpc-proxy/target/debian/btc-rpc-proxy_$(BTC_RPC_PROXY_VERSION)_$(DEB_ARCH).deb: btc-rpc-proxy
	cd btc-rpc-proxy; MAN_DIR=target/man cargo deb

clean_bitcoin_rpc_proxy:
	rm -rf btc-rpc-proxy
