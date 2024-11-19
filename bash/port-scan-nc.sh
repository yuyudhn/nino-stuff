#!/bin/bash
# Port scan with netcat
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <target_host> <start_port>-<end_port>"
    exit 1
fi

target_host=$1
port_range=$2
process_limit=200  # Set the maximum number of parallel processes

# Split start and end port
IFS='-' read -ra ports <<< "$port_range"
start_port="${ports[0]}"
end_port="${ports[1]}"

echo "Scanning ports $start_port to $end_port on $target_host..."
perform_scan() {
    local port=$1
    local result
    result=$(nc -zv -w 1 $target_host $port 2>&1)
    if [[ $result == *open* ]]; then
        echo "$result" | grep -Eo "\[[^]]+\] [0-9]+ \(.+\) open"
    fi
}

for ((port = start_port; port <= end_port; port++)); do
    perform_scan "$port" &
    if (( $(jobs -r | wc -l) >= process_limit )); then
        wait -n
    fi
done

wait
