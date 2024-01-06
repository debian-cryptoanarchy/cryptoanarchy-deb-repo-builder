name = "btcpayserver"
architecture = "any"
summary = "A cross platform, self-hosted server compatible with Bitpay API"
depends = ["dotnet-runtime-8.0", "aspnetcore-runtime-8.0"]
recommends = ["bitcoin-mainnet | bitcoin-regtest, btcpayserver-system-mainnet | bitcoin-regtest, btcpayserver-system-regtest | bitcoin-mainnet, btcpayserver-system-both | btcpayserver-system-mainnet | btcpayserver-system-regtest"]
add_files = ["/usr/lib/BTCPayServer"]
add_links = ["/usr/lib/BTCPayServer/BTCPayServer /usr/bin/btcpayserver"]
long_doc = """BTCPay Server is a free and open-source cryptocurrency payment processor which
allows you to receive payments in Bitcoin and altcoins directly, with no fees,
transaction cost or a middleman.

BTCPay is a non-custodial invoicing system which eliminates the involvement of
a third-party. Payments with BTCPay go directly to your wallet, which
increases the privacy and security. Your private keys are never uploaded to the
server. There is no address re-use, since each invoice generates a new address
deriving from your xpubkey.

The software is built in C# and conforms to the invoice API of BitPay. It
allows for your website to be easily migrated from BitPay and configured as a
self-hosted payment processor."""
