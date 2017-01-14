#!/usr/bin/env bash
set -eux
export DEBIAN_FRONTEND=noninteractive

mkdir -p /etc;
cp /tmp/bento-metadata.json /etc/bento-metadata.json;
chmod 0444 /etc/bento-metadata.json;
rm -f /tmp/bento-metadata.json;
