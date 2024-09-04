#!/bin/bash -ax
#SBATCH --job-name=run_iodaconv
#SBATCH --time=06:00:00
#SBATCH --account=star
##SBATCH --partition=s4
##SBATCH --nodes=1
##SBATCH --cpus-per-task=1
##SBATCH --exclusive
#SBATCH --partition=serial
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=94000
#SBATCH --output=/data/users/swei/runlogs/sub_iodaconv_log.%j

ulimit -s unlimited

export HDF5_USE_FILE_LOCKING='FALSE'

ndate="/home/swei/bin/ndate.py"
wrktmp="/scratch/users/swei/wrktmp"
pyscript=$JEDI_ROOT/build/bin/viirs_aod2ioda.py

source_dir="/ships19/aqda/bpierce/Satellite/VIIRS/AOD"

target_filename='viirs_npp_aod-thinned_p95'
target_dir="/data/users/swei/Dataset/jedi-data/input/obs/viirs_npp_aod-thinned_p95"
if [ ! -d $target_dir ]; then
    mkdir -p $target_dir
fi

sdate=2019070106
edate=2019073118
hint=6

cdate=$sdate
until [ $cdate -gt $edate ]
do
  rm $wrktmp/*
  echo "Process for cycle $cdate"
  cyc=${cdate:8:2}
  pdy=${cdate:0:8}
  case $cyc in
  00)
     pdate=`$ndate -6 $cdate`
     pdd=${pdate:6:2}
     p_pdy=${pdate:0:8}
     filelist="$source_dir/*s${p_pdy}2[1-3]* $source_dir/*s${pdy}0[0-2]*" ;;
  06)
     filelist="$source_dir/*s${pdy}0[3-8]*" ;;
  12)
     filelist="$source_dir/*s${pdy}09* $source_dir/*s${pdy}1[0-4]*" ;;
  18)
     filelist="$source_dir/*s${pdy}1[5-9]* $source_dir/*s${pdy}20*" ;;
  esac 
  for file in `ls $filelist`
  do
    echo $file
    tar -xf $file -C $wrktmp
  done

  outfile=${target_dir}/${target_filename}.${cdate}.nc4

  cd $wrktmp
  echo "$(date) Running: $pyscript"
  python $pyscript -i *.nc -n 0.95 -o $outfile --mask default --method default
  echo "$(date) End: $pyscript"
  cdate=`$ndate $hint $cdate`
done
