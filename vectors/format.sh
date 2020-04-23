#!/bin/bash
# Allows for '#' line comments, empty/whitespace lines, and 
# removes all instances of the characters ' and _ for 
# writing long numbers
set -e
if [ $# -ne 1 ]; then
    echo "usage: $0 <input file>"
    exit 1
fi
if [ ! -f $1 ]; then
    echo "$0: error: $1 does not exist"
    exit 1
fi
OUTF="$1.parsed"
echo "$OUTF:"
grep -vE '^#|^\s*$' $1 | sed "s/'//g; s/_//g" | tee $OUTF

