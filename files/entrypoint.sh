#!/bin/bash

# Exit immediatly if a command exists with non-zero status
set -e

# Start NGINX
nginx

# and Named
named -f -c /etc/named.conf
