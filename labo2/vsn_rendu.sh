#!/bin/bash

PROJECT_DIR=code/code3
SRC_DIR=code/src
REPORT_FILE=rapport.pdf
XML_FILE=code/com_store_velux.xml
RMDB_FILE=code/default.rmdb
PROJECT_FILE=src_tb/com_store_velux_tb.vhd
ARCHIVE=rendu.tar.gz

if [ ! -d "$PROJECT_DIR" ]
then
    echo "Could not find $PROJECT_DIR directory in $(pwd)" >&2
    exit 1
fi

if [ ! -d "$SRC_DIR" ]
then
    echo "Could not find $SRC_DIR directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$REPORT_FILE" ]
then
    echo "Could not find $REPORT_FILE directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$XML_FILE" ]
then
    echo "Could not find $XML_FILE directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$RMDB_FILE" ]
then
    echo "Could not find $RMDB_FILE directory in $(pwd)" >&2
    exit 1
fi

if [ ! -f "$PROJECT_DIR/$PROJECT_FILE" ]
then
    echo "Could not find project file : $PROJECT_FILE in $(realpath $PROJECT_DIR)" >&2
    exit 1
fi

echo "The following files are archived in $ARCHIVE : "
tar --exclude='rendu.tar.gz' --exclude='comp' -czvf $ARCHIVE $PROJECT_DIR $REPORT_FILE $RMDB_FILE $XML_FILE $SRC_DIR
