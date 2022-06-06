#!/bin/bash

target=$1

module purge
module load intel/18.0.5.274
module use /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
module load nemsio/2.2.4 bacio/2.0.3 sp/2.0.3 w3nco/2.0.7
module list

MAKE=`which make`

$MAKE -f Makefile.intel18 $target
