#!/bin/ksh

NLN="/bin/ln -sf"
ndate=/home/swei/bin/ndate.py
archive_expname='hazyda_ctrl_fcst'
CDUMP='gfs'

ARCDIR=/data/users/swei/archive/${archive_expname}

SDATE=2020061100
EDATE=2020062000
H_INT=24

CDATE=$SDATE
while [ $CDATE -le $EDATE ]
do
  datedir=$ARCDIR/$CDATE
  if [ ! -d $datedir ]; then 
     echo 'archive data does not exist'
     exit 2 
  else
     $NLN $datedir/*grib2 $ARCDIR
  fi

  CDATE=`python $ndate $H_INT $CDATE`
done
