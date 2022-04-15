#!/bin/ksh

machine='hera'

if [ $machine == 'hera' ]; then
   module purge
   module load intel/2022.1.2
   module use /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
   module load prod_util/1.1.0
   module list
fi

if [ $machine == 'cheyenne' ]; then
   USHDIR=/glade/u/home/swei/utils/nemsio_util/ush
elif [ $machine == 'hera' ]; then
   USHDIR=/home/Shih-wei.Wei/utils/nemsio_util/ush
   target_dir=/scratch1/NCEPDEV/global/Sarah.Lu/noscrub/gefs_nemsio_bin
   outputpath=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/JPSS/GEFS_AER
fi
NEMS2NC=${USHDIR}/nemsio_to_nc.sh

[[ ! -d $outputpath ]] && mkdir -p $outputpath

sdate=2019070109
edate=2019070221

cdate=$sdate
while [ $cdate -le $edate ]; do
  targetfile=$target_dir/geaer.${cdate}.atm.nemsio
  outputfile=$outputpath/geaer.${cdate}.atm.nc4

  sh $NEMS2NC $targetfile $outputfile $sfc_in $sfc_out $nst_in 

  cdate=`$NDATE 3 $cdate`
done
