#!/bin/ksh

machine='s4'

if [ $machine == 'hera' ]; then
   nems2nc=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/GSDChem_cycling/global-workflow/sorc/nemsio2nc.fd_Cory/nemsioatm2nc
elif [ $machine == 's4' ]; then
   module load license_intel/S4
   module load intel/18.0.3
   module load emc-hpc-stack/2020-q3
   module load hdf5/1.10.6
   module load netcdf/4.7.4
   module load bacio/2.4.1
   module load nemsio/2.5.2
   module load w3nco/2.4.1
   nems2nc=/home/swei/bin/nemsioatm2nc
   srun=`which srun`
   accnt='star'
   wtime='00:30:00'
   qos='debug'
   part='serial'
   outfile=/data/users/swei/tmp/log.nems2nc
fi

nems_in=$1
nc_out=$2

if [ -s $nems2nc ]; then
   $srun -n 1 -A $accnt -t $wtime -o $outfile $nems2nc $nems_in $nc_out 
else
   echo 'nemsioatm2nc not existed!!'
fi
