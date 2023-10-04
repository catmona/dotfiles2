#!/bin/bash 

exec ~/.themes/scheme "$(ls ~/.themes/colors | sed -e 's/\.ini$//' | tofi --prompt-text "scheme")"