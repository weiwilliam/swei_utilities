#!/bin/ksh
removedir=$1
lfs find $removedir -t f -print0 | xargs -0 -P 8 rm -f
