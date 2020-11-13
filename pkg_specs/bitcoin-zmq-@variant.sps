name = "bitcoin-zmq-@variant"
extends = "bitcoin-@variant"
replaces = false
summary = "ZMQ configuration for Bitcoin"

[map_variants.default_zmq_block_port]
mainnet = "28332"
regtest = "28442"

[map_variants.default_zmq_tx_port]
mainnet = "28333"
regtest = "28443"

[config."conf.d/zmq.conf"]
format = "plain"
public = true

[config."conf.d/zmq.conf".ivars.zmqpubrawblock]
type = "bind_host"
default = "tcp://127.0.0.1:{default_zmq_block_port}"
summary = "ZMQ address for publishing Bitcoin {variant} blocks"
priority = "low"

[config."conf.d/zmq.conf".ivars.zmqpubrawtx]
type = "bind_host"
default = "tcp://127.0.0.1:{default_zmq_tx_port}"
summary = "ZMQ address for publishing raw Bitcoin {variant} transactions"
priority = "low"
