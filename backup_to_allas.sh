#!/usr/bin/env bash

function tee_with_timestamps () {
    # Modified from https://stackoverflow.com/questions/39239379/add-timestamp-to-teed-output-but-not-original-output
    # answer by amleszk
    local logfile=$1
    while read data; do
        echo "${data}" | sed -e "s/^/[$(date '+%Y-%m-%dT%T')] /" >> "${logfile}"
        echo "${data}"
    done
}


while read -r line || [[ -n "$line" ]]; do
    arr=($line)
    echo Running s3cmd -c ~/.allas_bu_confs/project_${arr[0]} --no-progress sync ${arr[1]} s3://${arr[2]} 2>&1 | tee_with_timestamps ~/.allas_bu_confs/backups_${arr[0]}.log
    s3cmd -c ~/.allas_bu_confs/project_${arr[0]} --no-progress sync ${arr[1]} s3://${arr[2]} 2>&1 | tee_with_timestamps ~/.allas_bu_confs/backups_${arr[0]}.log
done < ~/.allas_bu_confs/config