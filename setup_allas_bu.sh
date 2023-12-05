#!/usr/bin/env bash
set -e

user=$(whoami)
project=("20012345" "20012346")


if ! [ -f allas_conf ]; then
    echo "allas_conf not found, please download it with"
    echo "wget https://raw.githubusercontent.com/CSCfi/allas-cli-utils/master/allas_conf"
    exit 1
fi


mkdir -p ${HOME}/.allas_bu_confs
# Make sure only the owner (or superusers) can access the key directory
chmod go-rwx ${HOME}/.allas_bu_confs/

for p in ${project[@]}; do
    if [ -f ${HOME}/.allas_bu_confs/project_$p ]; then
        echo ${HOME}/.allas_bu_confs/project_$p "exists, skipping."
        echo "If you want a new key and have already removed the old key with 'source allas_conf --s3remove', you can delete the config file and rerun this command." 
        continue
    fi

    . allas_conf -u ${user} -p project_$p -m s3cmd

    mv ${HOME}/.s3conf ${HOME}/.allas_bu_confs/project_$p
    # Make sure only the owner (or superusers) can access the key file
    chmod go-rwx ${HOME}/.allas_bu_confs/project_$p
done


if [ -f ${HOME}/.allas_bu_confs/config ]; then

cat > ${HOME}/.allas_bu_confs/config << __EOF__
20012345 /wrk/user/project1  backup
20012346 /wrk/user/project2  backup
__EOF__

    echo "Wrote example config to ${HOME}/.allas_bu_confs/config"

fi