#!/bin/ksh

USHDIR=/glade/u/home/swei/utils/nemsio_util/ush
NEMS2NC=${USHDIR}/nemsio_to_nc.sh

target_dir=/glade/work/swei/AerosolStudy/EnKF_mems/ICs

for mem in `seq -w 001 080`
do 
  echo $mem
done
