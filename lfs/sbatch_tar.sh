#!/bin/ksh
#SBATCH --job-name=sbatch_tar
#SBATCH --partition=service
#SBATCH --time=24:00:00
#SBATCH --nodes=1 --ntasks-per-node=1
#SBATCH --account=gsd-fv3-dev
#SBATCH --output=/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/Log/sbatch_tar.%j

. /apps/lmod/lmod/init/sh
module purge
module load intel
module use -a /contrib/anaconda/modulefiles
module load anaconda/latest
module list

ndate=/home/Shih-wei.Wei/bin/ndate.py
target_dir=/scratch1/NCEPDEV/global/Sarah.Lu/noscrub/hrrr_smoke_12hr
put_dir=/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/hrrr_smoke

cd $target_dir

sdate=2019091900
edate=2019093000

cdate=$sdate

while [ $cdate -le $edate ];
do
  echo $cdate
  pdy=`echo $cdate | cut -c1-8`
  cd $target_dir
  lfs find ./${pdy}* -t df -print0 | xargs -0 -P 8 tar -zcvf $put_dir/hrrr_smoke.${pdy}.tgz
  #tar -zcvf $put_dir/hrrr_smoke.${pdy}.tgz ${pdy}*
  cdate=`python $ndate 24 $cdate`
done

