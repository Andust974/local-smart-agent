#!/usr/bin/env bash
d="data/tg_bridge"
mkdir -p "$d"
pin="$(LC_ALL=C tr -dc 0-9 </dev/urandom | head -c 6)"
echo "$pin" > "$d/pin.txt"
echo "$pin"
