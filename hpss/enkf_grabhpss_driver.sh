#!/bin/ksh
# gdas enkf 
# Spectrum: gpfs_hps_nco_ops_com_gfs_prod_enkf.20170823_00.anl.tar
# FV3:      com_gfs_prod_enkfgdas.20210301_12.enkfgdas_restart_grp1.tar

export wrkdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrktmp

checkoutdate=$1
    cyc=`echo $checkoutdate | cut -c9-10`
tarprefix=gpfs_hps_nco_ops_com_gfs_prod_enkf
dump=anl
fileprefix="ratmanl nstanl sfcanl"

pull_members="01 02 03 04 05 21 22 23 24 25 41 42 43 44 45 61 62 63 64 65"

for mem_n in $pull_members
do
  for prefix in $fileprefix
  do
    targetfiles="$targetfiles ./gdas.t${cyc}z.${prefix}.mem0${mem_n}.nemsio"
  done
done
#echo "Pulling from HPSS:" $targetfiles

sh ./grabhpss.sh $checkoutdate $tarprefix $dump $targetfiles
rc=$?
if [ $rc -ne 0 ]; then
   exit
fi

if [ -d $wrkdir ]; then
   rm -rf $wrkdir/*
else
   mkdir -p $wrkdir
fi
cd $wrkdir

for mem_n in $pull_members
do
  mkdir -p $wrkdir/mem0$mem_n
  mv $wrkdir/*.mem0${mem_n}.nemsio $wrkdir/mem0$mem_n
  rc=$?
  if [ $rc -eq 0 ]; then
     cd $wrkdir
     tar -zcvf ${checkoutdate}.mem0${mem_n}.tgz ./mem0${mem_n}
  fi
done

