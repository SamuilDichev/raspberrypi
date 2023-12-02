#!/bin/bash

# Function to convert decimal to binary
dec2bin() {
    local n=$1
    local bin=""
    while [ $n -gt 0 ]; do
        bin=$(( $n % 2 ))$bin
        n=$(( $n / 2 ))
    done
    printf "%s\n" "$bin"
}

# Reverse a string
rev() {
    local str=$1
    local reversed=""
    for (( i=${#str}-1; i>=0; i-- )); do
        reversed="$reversed${str:$i:1}"
    done
    echo "$reversed"
}

# Convert hexadecimal to binary and print meanings
hex_to_binary_with_meaning() {
    local hex=$1
    local decimal=$(printf "%d\n" "$hex")
    local binary=$(dec2bin $decimal)
    local reversed_binary=$(rev "$binary")

    declare -A meanings=(
        [0]="Under-voltage detected"
        [1]="Arm frequency capped"
        [2]="Currently throttled"
        [3]="Soft temperature limit active"
        [16]="Under-voltage has occurred"
        [17]="Arm frequency capping has occurred"
        [18]="Throttling has occurred"
        [19]="Soft temperature limit has occurred"
    )

    for i in $(seq 0 $((${#reversed_binary} - 1))); do
        if [ "${reversed_binary:$i:1}" == "1" ] && [ ! -z "${meanings[$i]}" ]; then
            echo "WARNING $i: ${meanings[$i]}"
        fi
    done
}


# Output current configuration
vcgencmd get_config int | egrep "(arm|core|gpu|sdram)_freq|over_volt"

# Measure clock speeds
for src in arm core h264 isp v3d; do echo -e "$src:\t$(vcgencmd measure_clock $src)"; done

# Measure Volts
for id in core sdram_c sdram_i sdram_p ; do echo -e "$id:\t$(vcgencmd measure_volts $id)"; done

# Measure Temperature
vcgencmd measure_temp

# See if we are being throttled
echo ""
throttled="$(vcgencmd get_throttled)"
echo -e "$throttled"
if [[ $throttled != "throttled=0x0" ]]; then
    hex_value=$(echo $throttled | cut -d '=' -f2)
    hex_to_binary_with_meaning "$hex_value"
fi
