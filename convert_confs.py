#!/usr/bin/env python
import pathlib

"""
Run this file if you did the setup already with the s3cmd and want too switch to using rclone. If setting up from scratch now, ignore this file.

This will copy all old confs to a file with .bu suffix and make new confs with the old name.
"""


def copy_conf(infile, outfile):
    conf = {}
    with open(infile) as fi:
        for line in fi:
            if line.startswith("["):
                continue
            parts = line.split("=")
            conf[parts[0].strip()] = parts[1].strip()

    with open(outfile, "w") as fo:
        fo.write("[s3allas]\n")
        fo.write("type = s3\n")
        fo.write("provider = Other\n")
        fo.write("env_auth = false\n")
        fo.write(f"access_key_id = {conf['access_key']}\n")
        fo.write(f"secret_access_key = {conf['secret_key']}\n")
        fo.write("endpoint = a3s.fi\n")
        fo.write("acl = private\n")


for file in (pathlib.Path.home() / ".allas_bu_confs").iterdir():
    if file.name.startswith("project_"):
        tmp = file.rename(file.with_suffix(".bu"))
        copy_conf(tmp, file)
