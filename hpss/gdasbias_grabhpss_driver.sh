#!/bin/ksh
#SBATCH --output=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrklog/grab_radbias.out
#SBATCH --job-name=swei_grabradbias
#SBATCH --qos=batch
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
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
export wrkdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrktmp/grab_gdasbias
export desdir=/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/common/GDAS

[[ ! -d $wrkdir ]]&&mkdir -p $wrkdir

sdate=2020092100
edate=2020092118

checkoutdate=$sdate
while [ $checkoutdate -le $edate ]
do
cd $wrkdir
echo $pwd
pdy=`echo $checkoutdate | cut -c1-8`
cyc=`echo $checkoutdate | cut -c9-10`
dump=gdas
tarprefix=com_gfs_prod_gdas
tarsuffix=gdas

fsuffix_list="abias abias_pc abias_air"
targetfiles=""
for fsuffix in $fsuffix_list
do
  targetfiles=`echo $targetfiles ./${dump}.${pdy}/${cyc}/${dump}.t${cyc}z.${fsuffix}`
done
echo "Pulling from HPSS:" $targetfiles

sh $homedir/grabhpss.sh $checkoutdate $tarprefix $tarsuffix $targetfiles
rc=$?
if [ $rc -ne 0 ]; then
   exit
fi

#
if [ ! -d $desdir/${dump}.${pdy}/$cyc ]; then
   mkdir -p $desdir/${dump}.${pdy}/$cyc
fi
cd $wrkdir
mv $targetfiles $desdir/${dump}.${pdy}/$cyc
rc=$?
if [ $rc -ne 0 ]; then
   exit 1
fi

checkoutdate=`python $ndatepy 6 $checkoutdate`

done

exit 0
