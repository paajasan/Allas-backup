#!/usr/bin/env bash
set -e

function tee_with_timestamps () {
    # Modified from https://stackoverflow.com/questions/39239379/add-timestamp-to-teed-output-but-not-original-output
    # answer by amleszk
    local logfile=$1
    while read data; do
        echo "${data}" | sed -e "s/^/[$(date '+%Y-%m-%dT%T')] /" >> "${logfile}"
        echo "${data}"
    done
}


function aquire_lock () {
    local lockfile=$1
    local logfile=$2
    iter=0
    maxiter=60
    sleeptime=60
    while [ -f $lockfile ]; do
        read pid < $lockfile
        if ps -p $pid > /dev/null; then
            if [[ iter -gt maxiter ]]; then
                echo "Failed to aquire lock after $iter minutes" | tee_with_timestamps $logfile
                return 1
            fi 
            echo "$pid has lockfile, sleeping 60 s..." | tee_with_timestamps $logfile
            sleep 60
        else
            echo $lockfile is stale, removing!!!!! | tee_with_timestamps $logfile
            rm $lockfile
        fi
        let iter++
    done

    echo $$ > $lockfile
    echo "Aquired lockfile" $lockfile | tee_with_timestamps $logfile
    return 0
}


logfile=~/.allas_bu_confs/logfile.log
lockfile=~/.allas_bu_confs/lockfile.lock


if ! aquire_lock $lockfile $logfile ; then
    echo Cannot continue without lock file, please try again later. | tee_with_timestamps $logfile
    exit 1
fi

while read -r line || [[ -n "$line" ]]; do
    arr=($line)
    echo Running: rclone -l --config ~/.allas_bu_confs/project_${arr[0]} sync ${arr[1]} s3allas:${arr[2]} | tee_with_timestamps $logfile
    rclone -l --config ~/.allas_bu_confs/project_${arr[0]} sync ${arr[1]} s3allas:${arr[2]} 2>&1 | tee_with_timestamps $logfile
done < ~/.allas_bu_confs/config

rm $lockfile

echo All done for now! | tee_with_timestamps $logfile