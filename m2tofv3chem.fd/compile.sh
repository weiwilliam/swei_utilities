#!/bin/ksh

machine='s4'

if [ $machine == 's4' ]; then
   . /usr/share/lmod/lmod/init/sh
   
   module purge
   module load license_intel/S4
   module use /data/prod/hpc-stack/modulefiles/stack
   module load hpc/1.1.0
   # Load intel compiler and mpi
   module load hpc-intel/18.0.4
   module load hpc-impi/18.0.4
   module load netcdf/4.7.4
fi

cd ./fv3gfs_ncio

make clean
make -f makefile

if [ -s module_fv3gfs_ncio.o ]; then
   echo '!!Message!!: compile fv3gfs_ncio library successfully'
   cd ../
   make -f makefile
   if [ -s ./m2tofv3chem.x ]; then
      echo '!!Message!!: compile m2tofv3chem.x successfully'
   else
      echo '!!Message!!: compile m2tofv3chem.x fail'
      exit 2 
   fi
else
   echo '!!Message!!: compile fv3gfs_ncio fail'
   exit 1
fi

