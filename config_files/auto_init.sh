#!/bin/sh
FIRST_CONFIG="/.FIRST_CONFIG"
if [ ! -e $FIRST_CONFIG ]; then
    touch $FIRST_CONFIG
    /sbin/first_start.sh 
    exit   
else
    echo "Run /sbin/init directly"
    exit
fi