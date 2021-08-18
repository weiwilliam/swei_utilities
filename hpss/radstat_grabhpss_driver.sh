#!/bin/ksh
#SBATCH --output=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrklog/grab_radstat.out
#SBATCH --job-name=swei_grabradstat
#SBATCH --qos=batch
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --partition=service
#SBATCH --account=gsd-fv3-dev
# gdas enkf 
# Spectrum: gpfs_hps_nco_ops_com_gfs_prod_enkf.20170823_00.anl.tar
# FV3:      com_gfs_prod_enkfgdas.20210301_12.enkfgdas_restart_grp1.tar

. /apps/lmod/lmod/init/sh
module purge
module load intel/18.0.5.274
module use -a /contrib/anaconda/modulefiles
module load anaconda/latest
module load hpss
module list

ndatepy=${HOME}/bin/ndate.py

export homedir=/home/Shih-wei.Wei/utils/hpss
export wrkdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrktmp
export desdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/GDAS

sdate=2020083012
edate=2020092118

checkoutdate=$sdate
while [ $checkoutdate -le $edate ]
do
cd $wrkdir
echo $pwd
pdy=`echo $checkoutdate | cut -c1-8`
cyc=`echo $checkoutdate | cut -c9-10`
tarprefix=com_gfs_prod_gdas
dump=gdas

targetfiles="./gdas.$pdy/$cyc/gdas.t${cyc}z.radstat"
echo "Pulling from HPSS:" $targetfiles

sh $homedir/grabhpss.sh $checkoutdate $tarprefix $dump $targetfiles
rc=$?
if [ $rc -ne 0 ]; then
   exit
fi

sensor_list="iasi_metop-a iasi_metop-b"
loop_list="ges anl"
untar_list=""
for loop in $loop_list
do
  for sensor in $sensor_list
  do
    untar_list=`echo $untar_list diag_${sensor}_${loop}.${checkoutdate}.gz`
  done
done

#
if [ ! -d $desdir/${dump}.${pdy}/$cyc ]; then
   mkdir -p $desdir/${dump}.${pdy}/$cyc
fi
mv $wrkdir/$targetfiles $desdir/${dump}.${pdy}/$cyc
rc=$?
if [ $rc -eq 0 ]; then
   cd $desdir/${dump}.${pdy}/$cyc
   tar -xvf ${dump}.t${cyc}z.radstat $untar_list
   untar_rc=$?
fi

if [ $untar_rc -eq 0 ]; then
   gunzip $untar_list
else
   exit 1
fi

checkoutdate=`python $ndatepy 6 $checkoutdate`

done
