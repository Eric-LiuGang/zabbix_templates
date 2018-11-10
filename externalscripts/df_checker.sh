#!/bin/bash

line=$(ssh -o StrictHostKeyChecking=no -i $3 $2@$1 "df -B $5 $4 | tail -n 1")
total=$(echo $line | awk '{print $2}' | bc)
used=$(echo $line | awk '{print $3}' | bc)
avail=$(echo $line | awk '{print $4}' | bc)
pfree=$(echo "scale=2; $avail / $total *100" | bc -l | awk -F "." '{print $1}' | bc)
pused=$(echo "scale=2; $used / $total *100" | bc -l | awk -F "." '{print $1}' | bc)

if      [ $6 == "total" ]; then echo $total
elif    [ $6 == "used" ]; then echo $used
elif    [ $6 == "avail" ]; then echo $avail
elif    [ $6 == "pfree" ]; then echo $pfree
elif    [ $6 == "pused" ]; then echo $pused
fi
