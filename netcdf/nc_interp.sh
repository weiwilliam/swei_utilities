#!/bin/ksh
#SBATCH --job-name=m2aer_interp
#SBATCH --partition=s4
#SBATCH --time=03:30:00
#SBATCH --account=star
#SBATCH --nodes=1
##SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6000
#SBATCH --output=/data/users/swei/runlogs/m2aer_interp.%j
set -x
source /etc/bashrc
module purge
module load license_intel/S4
module load intel/2022.1
module load udunits2/2.2.28
module load hdf5/1.10.8
module load hdf/4.2.15
module load netcdf4/4.8.1
module load nco/5.0.4

ndate="python $HOME/bin/ndate.py"
NCFLINT=`which ncflint`
NCAP2=`which ncap2`
#SRUN=`which srun`
APRUN=' '
NLN="/bin/ln -sf"

target_dir=/data/users/swei/common/MERRA2_L64
wrktmp=/scratch/users/swei/ncinterp

sdate=2020081306
edate=2020092118
hint=6

cdate=$sdate
while [ $cdate -le $edate ];
do
  if [ ! -s $wrktmp ]; then
     mkdir -p $wrktmp
  else
     rm -rf $wrktmp/*
  fi
  cd $wrktmp

  m3_date=`$ndate -3 $cdate`
  p3_date=`$ndate  3 $cdate`

  cyy=${cdate:0:4}; cmm=${cdate:4:2}; chh=${cdate:8:2}
  m3_yy=${m3_date:0:4}; m3_mm=${m3_date:4:2}; m3_hh=${m3_date:8:2}
  p3_yy=${p3_date:0:4}; p3_mm=${p3_date:4:2}; p3_hh=${p3_date:8:2}

  cur_file=$target_dir/$cyy/$cmm/MERRA2_AER3D_FV3L64.${cdate}.nc
  m3_file=$target_dir/$m3_yy/$m3_mm/MERRA2_AER3D_FV3L64.${m3_date}.nc
  p3_file=$target_dir/$p3_yy/$p3_mm/MERRA2_AER3D_FV3L64.${p3_date}.nc
  $NLN $cur_file .
  $NLN $m3_file .
  $NLN $p3_file .

  # Output hour
  m2_date=`$ndate -2 $cdate` ; m2_hh=${m2_date:8:2}
  p2_date=`$ndate  2 $cdate`
  m1_date=`$ndate -1 $cdate` ; m1_hh=${m1_date:8:2}
  p1_date=`$ndate  1 $cdate`
  m3_savdir=$target_dir/$m3_yy/$m3_mm
  p3_savdir=$target_dir/$p3_yy/$p3_mm

  # Output file
  m2_file=MERRA2_AER3D_FV3L64.${m2_date}.nc
  m1_file=MERRA2_AER3D_FV3L64.${m1_date}.nc
  p2_file=MERRA2_AER3D_FV3L64.${p2_date}.nc
  p1_file=MERRA2_AER3D_FV3L64.${p1_date}.nc

  if [ -s $cur_file -a -s $m3_file ]; then
     $APRUN $NCFLINT -w 0.667,0.333 $m3_file $cur_file $m2_file &
     $APRUN $NCFLINT -w 0.333,0.667 $m3_file $cur_file $m1_file &
  else
     echo "$cur_file or $m3_file does not exist"
     exit
  fi

  if [ -s $cur_file -a -s $p3_file ]; then
     $APRUN $NCFLINT -w 0.667,0.333 $cur_file $p3_file $p1_file &
     $APRUN $NCFLINT -w 0.333,0.667 $cur_file $p3_file $p2_file &
  else
     echo "$cur_file or $p3_file does not exist"
     exit
  fi

  rc=1
  while [ $rc == 1 ]
  do
    if [ ! -s $m2_file -a \
         ! -s $m1_file -a \
         ! -s $p2_file -a \
         ! -s $p1_file ]; then
       sleep 10
    else
       if [ $chh == '00' ]; then
          $NCAP2 -s "time=time-time+60*${m2_hh}" $m2_file ${m2_file}.tmp &
          $NCAP2 -s "time=time-time+60*${m1_hh}" $m1_file ${m1_file}.tmp &
          while [ $rc == 1 ]
          do
            if [ ! -s ${m2_file}.tmp -a ! -s ${m1_file}.tmp ]; then
               sleep 10
            else
               mv ${m2_file}.tmp $m2_file
               mv ${m1_file}.tmp $m1_file
               rc=0
            fi
          done
       fi
       mv $m2_file $m3_savdir
       mv $m1_file $m3_savdir
       mv $p2_file $p3_savdir
       mv $p1_file $p3_savdir
       rc=0
    fi
  done
  cdate=`$ndate $hint $cdate`
done
