#!/bin/sh

for i in commands pulse
do
    for f in /dev/shm/queue/${i}/dead/*
    do
        find /dev/shm/queue/${i}/dead/ -iname "*.log" -delete
        if [[ -e ${f} ]]; 
        then
            mv  ${f} /dev/shm/queue/${i}/new/
        else
        continue
    fi
    done
done