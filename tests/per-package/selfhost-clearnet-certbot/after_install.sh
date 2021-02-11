#!/bin/bash

grep -q 'example\.com' /etc/hosts || echo '127.0.0.1 example.com' | sudo tee -a /etc/hosts >/dev/null || exit 1

wget -O /dev/null https://example.com || exit 1
