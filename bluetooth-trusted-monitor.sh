#!/bin/bash

# First, get the first controller id
ctlid=$(bluetoothctl list | head -n 1 | cut -d' ' -f 2)

while true; do
    delay=5

    for f in /var/lib/bluetooth/"${ctlid}"/*:*:*:*:*:*/info; do
        peerid=$(echo -n "${f}" | cut -d/ -f 6)
        if grep -q 'Trusted=true' "${f}"; then
            if bluetoothctl info "${peerid}" | grep -q 'Connected: no'; then
                echo "Trusted device ${peerid} appears disconnected, trying to reconnect..."
                if ! bluetoothctl connect "${peerid}"; then
                    delay=0.1
                fi
            fi
        fi
    done
    sleep "${delay}"
done

