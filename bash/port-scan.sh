#!/bin/bash

if [ "$1" == "" ]; then
    echo
    echo "This script scans TCP opened ports on IP or hostname"
    echo "Usage : portscan.sh <ip-or-hostname> [start-port] [end-port]"
    echo "start-port equals to 1 by default"
    echo "end-port equals 1024 by default"
    echo
    exit
fi

START_PORT=${2:-1}
END_PORT=${3:-1024}
TARGET_NAME_OR_IP=$1
PORT_PROTOCOL="tcp"
MAX_PARALLEL=50

echo "Scanning $TARGET_NAME_OR_IP (ports $START_PORT to $END_PORT)"
echo 'PORT	STATE	SERVICE'

scan_port(){
    PORT_NUMBER=$1
    PORT_SCAN_RESULT=$(2>&1 echo "" > /dev/$PORT_PROTOCOL/$TARGET_NAME_OR_IP/$PORT_NUMBER | grep connect)
    if [ "$PORT_SCAN_RESULT" == "" ]; then
        SERVICE=$(grep -m 1 "$PORT_NUMBER/$PORT_PROTOCOL" /etc/services | awk '{print $1}')
        echo "$PORT_NUMBER/$PORT_PROTOCOL	open	${SERVICE:-unknown}"
    fi
}

export -f scan_port
export TARGET_NAME_OR_IP
export PORT_PROTOCOL

parallel_scan() {
    local start_port=$1
    local end_port=$2
    local max_parallel=$3
    local active_jobs=0

    for port in $(seq $start_port $end_port); do
        scan_port $port &
        ((active_jobs++))
        if [ "$active_jobs" -ge "$max_parallel" ]; then
            wait -n
            ((active_jobs--))
        fi
    done
    wait
}

parallel_scan $START_PORT $END_PORT $MAX_PARALLEL