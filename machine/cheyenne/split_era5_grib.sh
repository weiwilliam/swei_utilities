#!/bin/ksh
set -x
module load grib-bins

NDATE=`ls ~/bin/ndate.py`
GRBCMD=`which wgrib`

wrkdir=/glade/scratch/swei/wrktmp
tardir=/glade/collections/rda/data/ds633.0/e5.oper.an.pl
arcdir=/glade/scratch/swei/ERA5

sdate=2020081300
edate=2020092118

var_list="z t q r w u v"

cdate=$sdate
while [ $cdate -le $edate ]
do
  if [ ! -d $wrkdir ];then
     mkdir -p $wrkdir
  else
     rm $wrkdir/*
  fi
  cd $wrkdir
  yy=${cdate:0:4}; mm=${cdate:4:2}; dd=${cdate:6:2} ; hh=${cdate:8:2}
  pdy=${cdate:0:8}; yy2=${cdate:2:2}

  for var in $var_list
  do
    grib_file=`ls ${tardir}/${yy}${mm}/e5.oper.an.pl.*${var}.ll025sc.${pdy}00_${pdy}23.grb`
    tmp_grib_file=$wrkdir/tmp_${var}.grib
    echo $grib_file
    $GRBCMD -s $grib_file | grep "d=${yy2}${mm}${dd}${hh}" | wgrib -i -grib \
            $grib_file -o $tmp_grib_file  
  done
  savedir=$arcdir/$yy/$mm
  if [ ! -d $savedir ]; then
     mkdir -p $savedir
  fi
  new_grib_file=$savedir/era5_${cdate}.grib
  [[ -s $new_grib_file ]]&&rm $new_grib_file
  cat tmp_*.grib >> $new_grib_file
  #echo $yy $mm $dd $hh
  cdate=`python $NDATE 6 $cdate`
done
