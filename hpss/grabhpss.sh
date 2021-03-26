#!/bin/ksh

module purge
module load hpss

cdate=$1
tarprefix=$2
dump=$3
targetfile=$4

yy=`echo $cdate | cut -c1-4`
mm=`echo $cdate | cut -c5-6`
dd=`echo $cdate | cut -c7-8`
hh=`echo $cdate | cut -c9-10`

# gdas enkf 
# Spectrum: gpfs_hps_nco_ops_com_gfs_prod_enkf.20170823_00.anl.tar
# FV3:      com_gfs_prod_enkfgdas.20210301_12.enkfgdas_restart_grp1.tar

tarball=${tarprefix}.${yy}${mm}${dd}_${hh}.${dump}.tar
hpsspath=/NCEPPROD/hpssprod/runhistory/rh${yy}/${yy}${mm}/${yy}${mm}${dd}

#/NCEPPROD/hpssprod/runhistory/rh2020/202006/20200622/com_gfs_prod_gdas.20200622_12.gdas.tar

hsi "ls ${hpsspath}/${tarball}"
ierr=$?
if [ $ierr -ne 0 ]; then
   exit    
fi

if [ -z $targetfile ] ;then
   htar -tvf ${hpsspath}/${tarball}
elif [ ! -z $targetfile ]; then
   echo 'targetfile=' $targetfile
   htar -xvf ${hpsspath}/${tarball} $targetfile 
fi

