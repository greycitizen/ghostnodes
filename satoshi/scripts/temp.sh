#!/bin/bash
#
# Data e hora
date
#
# Sensores
sensors

paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'

# Opção de mostrar em tempo real
#
echo "Show Temperature in Real Time?
#
Continue? [y/N]"
read resp
if [ $resp. != 'y.' ]; then
    exit 0
fi

watch -n 3 -d sensors
