# Allas-backup

Here are two scripts for setting up and running automated backups to the [Allas](https://docs.csc.fi/data/Allas/) service of CSC. These scripts might or might not work with other object storages.

The backups are a single snapshot of the latest state of your files, NOT an incremental history. If you remove a file locally, it will be removed in the next backup.

The command here use the S3 protocol, unlike the default Swift used in most commands with Allas. Any files larger than 5GB will break compatibility, so please only use S3 to upload/download to/from the backup buckets. You can of course use any protocol you wish in all your other buckets. If you already have a snapshot set up, it's easiest to just delete those and make a new one from scratch.

## A few general notes

1. These backups do **NOT** retain history. If you delete a file locally, it will be deleted on the remote during the next backup.
2. The scripts save access tokens in a plaintext file, so anyone with access to your home directory can access and modify the data in allas.
    - You can, however, revoke the access rights to any project at any time.
3. Anything in the destination that does not match a local file will be deleted or modified. In most cases it is best to just start with a fresh bucket.
4. The backup script uses a lockfile, so you should not be able to accidentally run multiple copies of it at the same time. If the lockfile is not released in the first 10 minutes, the script stops.
5. Symbolic links will simply be ignored
6. The quota for any single project is 10 TB by default. If you have more data, you'll need to either split it between multiple projects or ask CSC to increase the quota.


## Usage

### Dependencies

At least on university Cubbli it should be enough to install the openstack library for Python. Run 

    pip install openstackclient

OR if you have a conda environment set up (as you probably should)

    conda install python-openstackclient

If you are using the system python by default, you probably shouldn't. But if you do, you can try adding `--user` to the pip command. If that doesn't work you'll need to ask someone with sudo rights to install it for you.

### Setup script

First download two scripts

    wget https://raw.githubusercontent.com/CSCfi/allas-cli-utils/master/allas_conf
    wget https://raw.githubusercontent.com/paajasan/Allas-backup/main/setup_allas_bu.sh

The first one is from CSC (i.e. not written by me) to set up a connection to Allas, the second is from this repo.

#### Setting up the setup

Next, modify the options on the first few lines of setup_allas_bu.sh to set the CSC user (unless you have the same username on your desktop) and each project, which you will want to run these backups for. The projects do not necessarily have to be connected to the data, this defines which project will be billed for the storage space. This also defines under which project you can find your buckets in the [web GUI](https://pouta.csc.fi). 

#### Run the setup

The script makes conf files with the authentication keys for each project, and moves them to `$HOME/.allas_bu_confs/project_<number>`. It also make an example `conf` file which you should modify in the next step. Run it with

    bash setup_allas_bu.sh

It will first ask for your CSC password. If you mistype it, stop the script with `Ctrl-C` and remove the files in `$HOME/.allas_bu_confs/`.



#### Undoing the setup

If you ever want to remove access rights for the authentication keys, run 

    . allas_conf --s3remove [-u user]

The CSC username only has to be specified if it does not match your local username. You will have to run the command separately for each project.

After the keys are removed you can just delete the `$HOME/.allas_bu_confs/` folder with

    rm -r $HOME/.allas_bu_confs/

### Backup script

Download the backup script to the `.allas_bu_confs` directory and make it executable:

    wget https://raw.githubusercontent.com/paajasan/Allas-backup/main/backup_to_allas.sh -O $HOME/.allas_bu_confs/backup_to_allas.sh
    chmod u+x $HOME/.allas_bu_confs/backup_to_allas.sh



#### Configuration

Next modify the config file that the setup script made, e.g. with

    nano ~/.allas_bu_confs/config

The config is a simple text file with three whitespace separated columns. The first column gives the project number, second column the source directory (i.e. local directory to be backed up) and third column the target bucket (i.e. target detination where the backup will be made). For example the first line of the example is 

    20012345 /wrk/user/project1 backup

Which will backup the local directory `/wrk/user/project1` to `allas:backup` with settings for `project_20012345`. Each line will be run separately, so you can have multiple sources end up in different buckets under the same project with

    20012345 /wrk/user/project1/thing1 backup1
    20012345 /wrk/user/project4/thing2 backup2

Note that as the project on the first column is same for both lines, the third column has to differ. If the endpoints are set to be the same, the second command would end up overwriting the first.


#### Preparation of target

At this point make sure that the destination buckets exist. The backup script will NOT make them automatically. Easiest way is using the GUI at [pouta.csc.fi](https://pouta.csc.fi). The system might require the bucket names to be unique, so something like "backup_firstname_project" might be a good idea. If the destinations exist, make sure that they are empty as **the script will delete everything in the destination that does not match the local files.**


#### Running the script

You can run the script manually as

    $HOME/.allas_bu_confs/backup_to_allas.sh

Finally to make this script run automatically every week modify the user crontab with

    crontab -e

and add the line (remembering to substitute your username)

    23 1 * * 6 /home/[user]/.allas_bu_confs/backup_to_allas.sh

This runs the `setup_allas_bu.sh` script every Saturday night at 1:23. You can change the time slightly so that the network switch of our office will not get overwhelmed from everyone using it at the same time. However the script takes quite a long time as the command it uses for the syncing checks every files MD5 checksum. As such I recommend only runing this over the weekend.

After the script has run its backups, you can check log files under the same config folder, separated by project. You might want to check every now and then to confirm the scripts run without a problem.