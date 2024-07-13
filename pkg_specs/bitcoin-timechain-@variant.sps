name = "bitcoin-timechain-@variant"
extends = "bitcoin-rpc-proxy-@variant"
conflicts = ["nbxplorer-system-{variant} (<< 2.1.41)"]
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
	"getdeploymentinfo",
	"getdifficulty",
	"getnetworkinfo",
	"getnodeaddresses",
	"getmempoolinfo",
	"getmempoolentry",
	"getmempoolancestors",
	"getmempooldescendants",
	"getrawmempool",
	"gettxout",
	"gettxoutproof",
	"gettxoutsetinfo",
	"getzmqnotifications",
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
	# Used for NBXplorer
	"scantxoutset",
	"testmempoolaccept",
	"getnetworkhashps",
	"getmininginfo",
	"getblockstats",
	"getchaintxstats",
	"uptime",
	"getnettotals",
	"help",
	# Required for nbxplorer-*
	"getpeerinfo",
	"getindexinfo",
]
'''
