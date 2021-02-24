#!/bin/bash

PROJECT_DIR=code
PROJECT_FILE=src_tb/logger_example_tb.vhd
ARCHIVE=rendu.tar.gz

if [ ! -d "$PROJECT_DIR" ]
then
    echo "Could not find $PROJECT_DIR directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$PROJECT_DIR/$PROJECT_FILE" ]
then
    echo "Could not find project file : $PROJECT_FILE in $(realpath $PROJECT_DIR)" >&2
    exit 1
fi

echo "The following files are archived in $ARCHIVE : "
tar --exclude='rendu.tar.gz' --exclude='*.o' --exclude='comp' -czvf $ARCHIVE $PROJECT_DIR
