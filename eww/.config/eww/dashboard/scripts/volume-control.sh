#!/bin/bash

if [[ $1 != "" ]]; then
    pamixer --set-volume $1%
    eww update vol=$1
fi