# !/usr/bin/bash
# Bash script to copy and delete Files in / to destination folder
# Script owned by Apfelwerk GmbH & Co.KG
# Written by Benjamin Kollmer
# Copyright 21.09.2022
# Version 1.0.0
ph=$(printf '=%.0s' {1..12})

clear

# local directory and remote directory
localFiles="/Users/benjamin/NAS/local"
remoteFiles="/Users/benjamin/NAS/remote"

# rm .DS_Store file if exists in remote and local directory
if [ -f "$localFiles/.DS_Store" ]; then
    rm "$localFiles/.DS_Store"
fi
if [ -f "$remoteFiles/.DS_Store" ]; then
    rm "$remoteFiles/.DS_Store"
fi
# Info that the copy manager is going to start
echo "\n" $ph "Starting copy-manager" $ph "\n"

#check if directory is not empty
if [ ! "$(ls -A $localFiles)" ]; then
    echo "ERROR: No files in local directory"
    echo "INFO: Exit now..."
    echo "\n" $ph "Exiting..." $ph "\n"
    exit 1
else
    echo "INFO: Files in local directory where found. "
fi

echo "\n" $ph "GET local files" $ph "\n"

# get filename from local directory and remove everythin after the last dot
for file in $localFiles/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        filteredfilename="${filename%_*}"
        echo "INFO: $filteredfilename is lcoally available"
    fi
done
echo "\n"
echo  $ph "Compare and remove files at remote" $ph

# get remote filename and compare if filteredfilename is in filename and copy file to remote directory

if [ ! "$(ls -A $remoteFiles)" ]; then
    echo "INFO: No files in remote directory"
else
for file in $remoteFiles/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "INFO: File $filename in remote is available"
        if [[ $filename == *"$filteredfilename"* ]]; then
            echo "INFO: File $filename in remote will be deleted"
            rm -rf $file
        fi
    fi
done
fi

echo "\n" $ph "Copy file from local to remote" $ph "\n"

# copy file from local directory to remote directory
for file in $localFiles/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "INFO: Copy $filename to remote directory"
        cp -r $file $remoteFiles
    fi
done

echo "\n" $ph "Remove file from local, no further use " $ph "\n"

# after copying files to remote directory, remove files from local directory
for file in $localFiles/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "INFO: Remove $filename in local directory"
        rm -rf $file
    fi
done

echo "\n" $ph "Task ran successfully! Exiting..." $ph "\n"
