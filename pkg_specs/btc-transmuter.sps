name = "btc-transmuter"
architecture = "any"
summary = "A self-hosted ,modular IFTTT-inspired system for bitcoin services written in C# "
depends = ["dotnet-runtime-3.1", "aspnetcore-runtime-3.1"]
recommends = ["bitcoin-mainnet | bitcoin-regtest, btc-transmuter-system-mainnet | bitcoin-regtest, btc-transmuter-system-regtest | bitcoin-mainnet, btc-transmuter-system-both | btc-transmuter-system-mainnet | btc-transmuter-system-regtest"]
add_files = ["/usr/lib/BtcTransmuter"]
add_links = ["/usr/lib/BtcTransmuter/BtcTransmuter /usr/bin/btc-transmuter"]
long_doc = """BtcTransmuter is a free, open-source & self-hosted tool that
allows you to configure actions that execute automatically upon specified
conditions. Its primary focus is the integration of cryptocurrency services to
help users manage their funds and business workflow."""
