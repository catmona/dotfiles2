#!/bin/bash

if [[ $1 != "" ]]; then
    pamixer --quiet set Capture $1%
    eww update rec=$1
fi