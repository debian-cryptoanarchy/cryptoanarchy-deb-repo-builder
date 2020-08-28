name = "python3-lnpbp-testkit"
architecture = "any"
summary = "A framework for writing automated tests of LNP/BP applications"
depends = ["${python3:Depends}", "${misc:Depends}", "bitcoin-regtest", "lnd-system-regtest", "python3 (>= 3.8) | python3-typing-extensions"]
add_files = ["lnd-testkit-regtest@.service /usr/lib/systemd/user"]
