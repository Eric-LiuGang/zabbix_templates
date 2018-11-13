#!/bin/bash

##############################################################################################################
### PARAMETER INITIALIZATION

hostname=$1             # destination IP address / DNS name
username=$2             # zabbix
privkey=$3              # /data/zabbix/.ssh/id_rsa
request_type=$4 # "size" / "inode" / "load"
request_spec=$5 # for example: total / free / pfree / 1m
arg1=$6                 # device name: /dev/md2
arg2=$7                 # blocksize: 1014
arg3=$8                 # for future use

##############################################################################################################
### FUNCTIONS

pre_checking () {
                # +-------------------------------------------+
                # Destination host check
                ping -c1 $hostname > /dev/null
                if [ $? -eq 1 ]; then
                        echo "!! Destination host is unreachable"
                        exit
                fi

                # +-------------------------------------------+
                # Private key check
                if [ ! -f $privkey ]; then
                        echo "!! Private key not found at $3"
                        exit
                fi
}

df_calc ()      {
        total=$(echo $line | awk '{print $2}' | bc)
        used=$(echo $line | awk '{print $3}' | bc)
        free=$(echo $line | awk '{print $4}' | bc)
        pfree=$(echo "scale=2; $free / $total *100" | bc -l | awk -F "." '{print $1}' | bc)
        pused=$(echo "scale=2; $used / $total *100" | bc -l | awk -F "." '{print $1}' | bc)
}

df_show ()      {
        if      [ "$request_spec" == "total" ]; then echo $total
        elif    [ "$request_spec" == "used" ]; then echo $used
        elif    [ "$request_spec" == "free" ]; then echo $free
        elif    [ "$request_spec" == "pfree" ]; then echo $pfree
        elif    [ "$request_spec" == "pused" ]; then echo $pused
        fi
}

load_select ()  {
        load1=$(echo $line | awk -F ": " '{print $2}' | sed 's/, /;/g' | awk -F ";" '{print $1}' | bc)
        load2=$(echo $line | awk -F ": " '{print $2}' | sed 's/, /;/g' | awk -F ";" '{print $2}' | bc)
        load3=$(echo $line | awk -F ": " '{print $2}' | sed 's/, /;/g' | awk -F ";" '{print $3}' | bc)
}

load_show ()  {
        if      [ "$request_spec" == "1m" ]; then echo $load1
        elif    [ "$request_spec" == "5m" ]; then echo $load2
        elif    [ "$request_spec" == "15m" ]; then echo $load3
        fi
}

##############################################################################################################
### MAIN
pre_checking

if [ $request_type == "size" ]; then
        line=$(ssh -o StrictHostKeyChecking=no -i $privkey $username@$hostname "df -B $arg2 $arg1 | tail -n 1")
        df_calc
        df_show

elif [ $request_type == "inode" ]; then
        line=$(ssh -o StrictHostKeyChecking=no -i $privkey $username@$hostname "df -i $arg1 | tail -n 1")
        df_calc
        df_show

elif [ $request_type == "load" ]; then
        line=$(ssh -o StrictHostKeyChecking=no -i $privkey $username@$hostname "uptime")
        load_select
        load_show
fi


