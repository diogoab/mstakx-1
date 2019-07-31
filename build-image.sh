#!/bin/bash

if [ -f "./key/ssh-key" ]
then
    docker build -t deploy-cluster .
else
    echo "File ssh-key don't exist. Verify the file and correct path (inside mstakx project)"
    exit 5
fi
