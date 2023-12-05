# Allas-backup

Here are two scripts for setting up and running automated backups to the [Allas](https://docs.csc.fi/data/Allas/) service of CSC. These scripts might or might not work with other object storages.

The backups are a single snapshot of the latest state of your files, NOT an incremental history. If you remove a file locally, it will be removed in the next backup.

The command here use the S3 protocol, unlike the default Swift used in most commands with Allas. Any files larger than 5GB will break compatibility, so please only use S3 to upload/download to/from the backup buckets. You can of course use any protocol you wish in all your other buckets. If you already have a snapshot set up, it's easiest to just delete those and make a new one from scratch.

## Scripts

### Setup script

First download the needed scripts

    wget https://raw.githubusercontent.com/CSCfi/allas-cli-utils/master/allas_conf
    wget https://raw.githubusercontent.com/paajasan/Allas-backup/main/setup_allas_bu.sh

Next, modify the options on the first few lines of setup_allas_bu.sh to set the CSC user (unless you have the same username on your desktop) and each project, which you will want to run these backups for.

The script makes conf files with the authentication keys for each project, and moves them to `$HOME/.s3_confs/project_<number>`.

### Backup script


    wget https://raw.githubusercontent.com/paajasan/Allas-backup/main/setup_allas_bu.sh