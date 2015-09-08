#!/bin/bash

PREFIX="mystore.kstat.$(hostname | cut -d '.' -f 1)_ms_virtua_ch.cpu"

STATSD_IP="stats.ms.virtua.ch"
STATSD_PORT="8125"

NC="$(which nc)"

## grep some metrics based on following values :
#    above_base_sec
#    above_sec
#    baseline
#    below_sec
#    burst_limit_sec
#    bursting_sec
#    class
#    crtime
#    effective
#    maxusage
#    nwait
#    snaptime
#    usage
#    value
#    zonename

## scope for kstat
function kstats() {
    kstat -p caps::cpucaps_zone*
}

## values to be compute before sending to statsd 
CPU_USAGE="$(kstats | grep ':usage' | awk '{ print $2 }')"
CPU_BASELINE="$(kstats | grep ':baseline' | awk '{ print $2 }')"
CPU_MAXUSAGE="$(kstats | grep ':maxusage' | awk '{ print $2 }')"
CPU_CAP="$(kstats | grep ':value' | awk '{ print $2 }')"

## Send values to statsd
while [ 1 ]
do
    echo "${PREFIX}.usage:${CPU_USAGE}|g
${PREFIX}.baseline:${CPU_BASELINE}|g
${PREFIX}.maxusage:${CPU_MAXUSAGE}|g
${PREFIX}.cap:${CPU_CAP}|g" | ${NC} -u -w0 ${STATSD_IP} ${STATSD_PORT}
    sleep 10
done
