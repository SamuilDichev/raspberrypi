#!/bin/bash
temp=$(sensors -u | grep "temp1_input" | grep -oP "[0-9]+\.[0-9]+")
comparison=$(echo "$temp > 70" | bc)

if [ $comparison -eq 1 ]; then
  echo "Temp is $temp, turning ON the USB hub"
  uhubctl -l "1-1" -a on > /dev/null
else
  echo "Temp is $temp, turning OFF the USB hub"
  uhubctl -l "1-1" -a off > /dev/null
fi
