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

read -s -p "CSC password: " pwd
echo

for p in ${project[@]}; do
    if [ -f ${HOME}/.allas_bu_confs/project_$p ]; then
        echo ${HOME}/.allas_bu_confs/project_$p "exists, skipping."
        echo "If you want a new key and have already removed the old key with 'source allas_conf --s3remove', you can delete the config file and rerun this command." 
        continue
    fi

    OS_PASSWORD=$pwd bash allas_conf -u ${user} -p project_$p -m s3cmd -f

    echo mv ${HOME}/.s3cfg ${HOME}/.allas_bu_confs/project_$p
    mv ${HOME}/.s3cfg ${HOME}/.allas_bu_confs/project_$p

    # Make sure only the owner (or superusers) can access the key file
    chmod go-rwx ${HOME}/.allas_bu_confs/project_$p
done


if ! [ -f ${HOME}/.allas_bu_confs/config ]; then


    for p in ${project[@]}; do
        echo $p /wrk/$(whoami)/project_$p backup
    done | cat > ${HOME}/.allas_bu_confs/config

    echo "Wrote example config to ${HOME}/.allas_bu_confs/config"

fi
