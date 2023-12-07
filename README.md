# Allas-backup

Here are two scripts for setting up and running automated backups to the [Allas](https://docs.csc.fi/data/Allas/) service of CSC. These scripts might or might not work with other object storages.

The backups are a single snapshot of the latest state of your files, NOT an incremental history. If you remove a file locally, it will be removed in the next backup.

The command here use the S3 protocol, unlike the default Swift used in most commands with Allas. Any files larger than 5GB will break compatibility, so please only use S3 to upload/download to/from the backup buckets. You can of course use any protocol you wish in all your other buckets. If you already have a snapshot set up, it's easiest to just delete those and make a new one from scratch.

## Scripts

### Setup script

First download two scripts

    wget https://raw.githubusercontent.com/CSCfi/allas-cli-utils/master/allas_conf
    wget https://raw.githubusercontent.com/paajasan/Allas-backup/main/setup_allas_bu.sh

The first one is from CSC to set up a connection to Allas (i.e. not written by me), the second is from this repo.

Next, modify the options on the first few lines of setup_allas_bu.sh to set the CSC user (unless you have the same username on your desktop) and each project, which you will want to run these backups for.

The script makes conf files with the authentication keys for each project, and moves them to `$HOME/.allas_bu_confs/project_<number>`. It also make an example `conf` file which you should modify in the next step.

### Backup script

Download the backup script to the `.allas_bu_confs` directory:

    wget https://raw.githubusercontent.com/paajasan/Allas-backup/main/setup_allas_bu.sh -P $HOME/.allas_bu_confs/

Next modify the config file that the setup script made, e.g. with

    nano ~/.allas_bu_confs/config

The config is a simple text file with three whitespace separated columns. The first column gives the project number, second column the source directory and third column the target bucket. For example the first line of the example is 

    20012345 /wrk/user/project1 backup

Which will backup the local directory `/wrk/user/project1` to `allas:backup` with settings for `project_20012345`. Each line will be run separately, so you can have multiple sources end up in different buckets under the same project with

    20012345 /wrk/user/project1/thing1 backup1
    20012345 /wrk/user/project4/thing2 backup2


Finally to make this script run automatically every day modify the user crontab with

    crontab -e

and add the line

    23 1 * * * /home/user/.allas_bu_confs/setup_allas_bu.sh

This runs the `setup_allas_bu.sh` script every night at 1:23. You can change the time slightly so that the network switch of our office will not get overwhelmed from everyone using it at the same time.