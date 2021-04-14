#!/bin/bash

machine=$1
target=$2

if [ $machine == 'hera' ]; then
   module purge
   module load intel/18.0.5.274
   module use /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
   module load nemsio/2.2.4 bacio/2.0.3 sp/2.0.3 w3nco/2.0.7 netcdf
   module list
elif [ $machine == 's4' ]; then
   module purge
   module load license_intel/S4
   module load intel/18.0.3
   module load emc-hpc-stack/2020-q3
   module load netcdf/4.7.4
   module load bacio/2.4.1
   module load w3nco/2.4.1
   module load nemsio/2.5.2
elif [ $machine == 'chy' ]; then
   module purge
   module load intel
   module load netcdf
   export NCEPLIBS=/glade/work/swei/NCEPLIBS/lib
   export NCEP_INC=/glade/work/swei/NCEPLIBS/include
   export BACIO_LIB4=$NCEPLIBS/libbacio_4.a
   export W3NCO_LIB4=$NCEPLIBS/libw3nco_v2.0.6_4.a
   export NEMSIO_LIB=$NCEPLIBS/libnemsio_d.a
   export NEMSIO_INC=$NCEP_INC
fi

MAKE=`which make`

if [ -z $target ]; then
   $MAKE -f makefile all
else
   $MAKE -f makefile $target
fi
