#! /bin/bash

while ! /usr/bin/puppet agent; do
    :
done
