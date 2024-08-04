#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 192.168.1.1-255"
    exit 1
fi

ip_range=$1

# Extract base IP and range
IFS='.-' read -r a b c start_range end_range <<< "${ip_range}"

is_alive_ping() {
    ping -c 1 -W 1 $1 > /dev/null
    [ $? -eq 0 ] && echo "$1"
}

for i in $(seq "$start_range" "$end_range"); do
    ip="$a.$b.$c.$i"
    is_alive_ping "$ip" &

    if (( $(jobs -r | wc -l) >= 200 )); then
        wait -n
    fi
done

wait
