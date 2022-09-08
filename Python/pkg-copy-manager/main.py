# !/usr/bin/python3
# Python script to copy and delete Files in / to destination folder
# Script owned by Apfelwerk GmbH & Co.KG
# Written by Benjamin Kollmer
# Copyright 07.09.2022
# Version 1.0.0

import os, shutil, argparse

# Placeholder
ph = "-" * 15

def compare_files(array, remoteFiles):
    # Check if filenames from Local exists in destination folder
    for lfname in remoteFiles:
        if lfname in remoteFiles:
            try:
                array[lfname.split("_", maxsplit=1)[0]]["exists"] = True
                array[lfname.split("_", maxsplit=1)[0]]["oldName"] = lfname
                print("INFO-File: " + lfname + " exists in destination folder")
            except:
                array[lfname.split("_", maxsplit=1)[0]]["oldName"] = lfname
                print("WARN-File: " + lfname + " does not exist on local disk")
        else:
            array[lfname.split("_", maxsplit=1)[0]]["oldName"] = lfname
    return array


def update_files(array, remotePath):
    # Copy files to destination folder
    for file in array:
        if array[file]["fileName"] == array[file]["oldName"]:
            print("SKIP-File: " + file + " is already up to date, skipping")
        else:
            if array[file]["exists"] == False:
                shutil.copy2(array[file]["path"], remotePath)
                print("CP-File: " + array[file]["fileName"] + " copied to destination folder")
            else:
                # remove old file from destination folder
                print("RM-File: removing old version " + array[file]["oldName"])
                os.remove(os.path.join(remotePath, array[file]["oldName"]))

                # replace file in destination folder with newer version
                shutil.copy2(array[file]["path"], remotePath)
                print(
                    "CP-File: "
                    + array[file]["fileName"]
                    + " copied newer version, to destination folder"
                )


def main():
    # get arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-lp",
        "--localPath",
        nargs=1,
        help="Path to local package folder.  Must supply <local-path>",
    )
    parser.add_argument(
        "-rp",
        "--remotePath",
        nargs=1,
        help="Path to remote package folder (e.g. destination folder).  Must supply <remote-path>",
    )
    args = parser.parse_args()

    # check if arguments are smissing
    if args.localPath is None or args.remotePath is None:
        parser.print_help()
        exit(1)
    else:
        # check if paths are valid
        print(str(args.localPath[0]))
        if not os.path.isdir(args.localPath[0]):
            print("ERROR: Local path is not valid, please check if it exists.")
            exit(1)
        if not os.path.isdir(args.remotePath[0]):
            print("ERROR: Remote path is not valid, please check if it exists.")
            exit(1)

        localPath = args.localPath[0]
        remotePath = args.remotePath[0]

    # Create a list of all the files in the destination folder folder and  filter pkg files
    remoteFiles = os.listdir(remotePath)
    remoteFiles = [x for x in remoteFiles if x.endswith(".pkg")]

    # Create a list of all the files in the localPath folder and  filter pkg files
    localFiles = os.listdir(localPath)
    localFiles = [x for x in localFiles if x.endswith(".pkg")]

    # check if there are any .pkg files in the local folder
    if len(localFiles) == 0:
        print("INFO: There are no .pkg files in the local folder.")
        exit(1)

    # Print the list of files in the Local folder
    print("\n", ph, " List all Local PKGs " + ph, "\n")

    # Get filename without version number
    for fname in localFiles:
        lfname = fname.split("_", maxsplit=1)[0]
        print("INFO-File: " + lfname + " exists in Local Folder")

    # Create Array of Files in localFiles folder
    array = {}
    for fnum in localFiles:
        obj = {
            "fileName": fnum,
            "path": os.path.join(localPath, fnum),
            "exists": False,
            "oldName": "",
        }
        array[fnum.split("_", maxsplit=1)[0]] = obj

    # Check if filenames from Local exists in destination folder
    print("\n", ph, "Check if file exists in destination folder", ph, "\n")
    array = compare_files(array, remoteFiles)

    # Copy files to destination folder
    print("\n", ph, "Update files in destination folder", ph, "\n")
    update_files(array, remotePath)

    print("\n", ph, "Task ran successfully! Exiting... ", ph, "\n")


if __name__ == "__main__":
    main()
