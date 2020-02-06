name = "bitcoin-timechain-mainnet"
version = "0.1"
extends = "bitcoin-rpc-proxy-mainnet"
summary = "RPC proxy configuration for accessing timechain-related calls"

[config."conf.d/public.conf"]
public = true
content = '''
[user.public]
password = "public"
allowed_calls = [
	# Deprecated, but LND still accesses it. WTF
	"getinfo",
	"getblock",
	"getblockchaininfo",
	"getbestblockhash",
	"getblockcount",
	"getblockhash",
	"getblockheader",
	"getchaintips",
	"getdifficulty",
	"getnetworkinfo",
	"getmempoolinfo",
	"getrawmempool",
	"gettxout",
	"gettxoutproof",
	"gettxoutsetinfo",
	"verifytxoutproof",
	"createrawtransaction",
	"decoderawtransaction",
	"decodescript",
	"getrawtransaction",
	"sendrawtransaction",
	"estimatefee",
	"estimatepriority",
	"estimatesmartfee",
	"estimatesmartpriority",
	"validateaddress",
	"signrawtransactionwithkey",
	# Warning: may be used for DoS and possibly to correlate identities!
	# Used for NBXplorer - see below.
	"scantxoutset",
	# NBXplorer needs this call to be enabled
	# There's a proposal to fix that
	# See https://github.com/MetacoSA/NBitcoin/issues/808
	# So hopefully, this is temporary.
	"generatetoaddress",
]
'''
