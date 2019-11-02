name = "bitcoin-zmq-mainnet"
version = "0.18.1"
extends = "bitcoin-mainnet"
replaces = false
summary = "ZMQ configuration for Bitcoin"

[config."conf.d/zmq.conf"]
format = "plain"
public = true

[config."conf.d/zmq.conf".ivars.zmqpubrawblock]
type = "bind_host"
default = "tcp://127.0.0.1:28332"
summary = "ZMQ address for publishing Bitcoin blocks"
priority = "low"

[config."conf.d/zmq.conf".ivars.zmqpubrawtx]
type = "bind_host"
default = "tcp://127.0.0.1:28333"
summary = "ZMQ address for publishing raw Bitcoin transactions"
priority = "low"
