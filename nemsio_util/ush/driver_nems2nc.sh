#!/bin/ksh

USHDIR=/glade/u/home/swei/utils/nemsio_util/ush
NEMS2NC=${USHDIR}/nemsio_to_nc.sh

target_dir=/glade/work/swei/AerosolStudy/EnKF_mems/ICs

for mem in `seq -w 001 080`
do 
  echo $mem
  if [ -d $target_dir/mem$mem ] ; then
     atm_in=gdas.t00z.ratmanl.mem${mem}.nemsio
     sfc_in=gdas.t00z.sfcanl.mem${mem}.nemsio
     nst_in=gdas.t00z.nstanl.mem${mem}.nemsio
     atm_out=gdas.t00z.ratmanl.mem${mem}.nc4
     sfc_out=gdas.t00z.sfcanl.mem${mem}.nc4
     $NEMS2NC $atm_in $atm_out $sfc_in $sfc_out $nst_in 
  fi
done
