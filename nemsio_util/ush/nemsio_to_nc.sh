#!/bin/ksh

nems2nc=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/GSDChem_cycling/global-workflow/sorc/nemsio2nc.fd_Cory/nemsioatm2nc

nems_in=$1
nc_out=$2

if [ -s $nems2nc ]; then
   $nems2nc $nems_in $nc_out
else
   echo 'nemsioatm2nc not existed!!'
fi
