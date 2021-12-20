#!/bin/ksh --login
#SBATCH --output=/data/users/swei/tmp/m2_split2fv3lv64.log
#SBATCH --job-name=m2_split2fv3lv64
#SBATCH --time=06:00:00
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=4
##--ntasks-per-node=$procs --cpus-per-task=$threads
##SBATCH --mem-per-cpu=6000
#SBATCH --partition=s4
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --account=star
#SBATCH --distribution=block:block


machine='s4'

if [ $machine == 'hera' ]; then
   . /apps/lmod/lmod/init/sh
   module purge
   module load intel
   module load impi
   module load netcdf
   module load nco
   module use -a /contrib/anaconda/modulefiles
   module load anaconda/latest
elif [ $machine == 's4' ]; then
   . /usr/share/lmod/lmod/init/sh
   module purge
   module load license_intel/S4
   module use /data/prod/hpc-stack/modulefiles/stack
   module load hpc/1.1.0
   module load hpc-intel/18.0.4
   module load hpc-impi/18.0.4
   module load netcdf/4.7.4
   module load miniconda/3.8-s4
   module load nco/4.9.3
fi

module list

ndate="python $HOME/bin/ndate.py"

if [ $machine == 'hera' ]; then 
   m2tofv3='/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/util/m2tofv3chem.fd/m2tofv3chem.x'
   indir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/MERRA2
   outdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/MERRA2
elif [ $machine == 's4' ]; then
   m2tofv3='/home/swei/utils/m2tofv3chem.fd/m2tofv3chem.x'
   indir=/data/users/swei/common/MERRA2
   outdir=/data/users/swei/common/MERRA2_L64
fi

sdate=2020082100
edate=2020082118

cdate=$sdate
while [ $cdate -le $edate ];
do
  pdy=`echo $cdate | cut -c1-8`
  y4=`echo $cdate | cut -c1-4`
  mm=`echo $cdate | cut -c5-6`
  dd=`echo $cdate | cut -c7-8`
  if [ ! -d $outdir/$y4/$mm ]; then
     mkdir -p $outdir/$y4/$mm
  fi
  #infile=$indir/$y4/$mm/MERRA2_401.inst3_3d_aer_Nv.${pdy}.nc4
  infile=$indir/$y4/$mm/MERRA2_400.inst3_3d_aer_Nv.${pdy}.nc4
  echo "INPUT: $infile"
  tdate=$cdate
  #for t in 0 2 4 6 # MERRA2 AOD file is 3-hourly
  #for t in 0 1 2 3 
  for t in 0 1 2 3 4 5 6 7
  do
    echo "processing ${tdate}"
    hh=`echo $cdate | cut -c9-10`
    outfile=$outdir/$y4/$mm/MERRA2_AER3D.${tdate}.nc
    echo "OUTPUT: $outfile"
    m2l64file=$outdir/$y4/$mm/MERRA2_AER3D_FV3L64.${tdate}.nc
    ncks -d time,$t,$t $infile $outfile
    $m2tofv3 $outfile $m2l64file
    if [ -s $m2l64file ]; then
       rm -rf $outfile
    fi
    tdate=`$ndate 3 $tdate`
  done
  cdate=`$ndate 24 $cdate`
done

