#!/bin/bash

eww close control-center
if [[ $1 != "" ]]; then
    kitty -e lf $1
fi