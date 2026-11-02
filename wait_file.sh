#!/bin/bash
set -euo pipefail

TRT="/tmp/ready"
TIMEOUT=30
INTERVAL=2
elapsTime=0

while [ $elapsTime -lt $TIMEOUT ]; do
    if [ -f $TRT ]; then
        echo "file appeared in ${elapsTime} seconds"
        exit 0
    fi

    sleep $INTERVAL
    elapsTime=$((elapsTime + INTERVAL))
done

echo "timeout: file didnt appear" >&2
exit 1
