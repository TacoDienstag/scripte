#!/usr/bin/env bash
# Bash script to run the python copy and delete manager
# Script owned by Apfelwerk GmbH & Co.KG
# Written by Benjamin Kollmer
# Copyright 05.09.2022
# Version 1.0.0

# Arguments for Localpath and RemotePath on google drive
# Replace with your own relative paths
# Default for Google Drive: /Volumes/GoogleDrive/Geteilte Ablagen/JAMF Resources/PKGs

python3 main.py -lp "/Users/admin/pkgs" -rp "/Users/admin/NAS PKGs"