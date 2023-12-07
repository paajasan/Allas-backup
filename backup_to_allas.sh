#!/usr/bin/env bash


while read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
done < my_filename.txt