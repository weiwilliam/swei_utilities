#!/bin/ksh
# gdas enkf 
# Spectrum: gpfs_hps_nco_ops_com_gfs_prod_enkf.20170823_00.anl.tar
# FV3:      com_gfs_prod_enkfgdas.20210301_12.enkfgdas_restart_grp1.tar

export wrkdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrktmp

checkoutdate=$1
    pdy=`echo $checkoutdate | cut -c1-8`
    cyc=`echo $checkoutdate | cut -c9-10`
tarprefix=com_gfs_prod_gdas
dump=gdas

targetfiles="./gdas.$pdy/$cyc/gdas.t${cyc}z.radstat"
#echo "Pulling from HPSS:" $targetfiles

sh ./grabhpss.sh $checkoutdate $tarprefix $dump $targetfiles
rc=$?
if [ $rc -ne 0 ]; then
   exit
fi

#cd $wrkdir
#echo $pwd
#
#  mkdir -p $wrkdir/mem0$mem_n
#  mv $wrkdir/*.mem0${mem_n}.nemsio $wrkdir/mem0$mem_n
#  rc=$?
#  if [ $rc -eq 0 ]; then
#     cd $wrkdir
#     tar -zcvf ${checkoutdate}.mem0${mem_n}.tgz ./mem0${mem_n}
#  fi
#done

