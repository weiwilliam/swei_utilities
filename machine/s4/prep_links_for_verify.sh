#!/bin/ksh

NLN="/bin/ln -sf"
ndate=/home/swei/bin/ndate.py
analarch_expname="hazyda_ctrl"
archive_expname="${analarch_expname}_fcst"
fcstCDUMP='gfs'
analCDUMP='gdas'

analARCDIR=/data/users/swei/archive/${analarch_expname}
fcstARCDIR=/data/users/swei/archive/${archive_expname}
scraARCDIR=/scratch/users/swei/archive/${archive_expname}
if [ ! -d $scraARCDIR ]; then
   mkdir -p $scraARCDIR
fi

SDATE=2020061000
EDATE=2020071000
H_INT=24

CDATE=$SDATE
while [ $CDATE -le $EDATE ]
do
  f_datedir=$fcstARCDIR/$CDATE
  if [ ! -d $f_datedir ]; then 
     echo 'archive data does not exist'
     exit 2 
  else
     $NLN $f_datedir/*grib2 $scraARCDIR
     #$NLN $f_datedir/*grib2 $fcstARCDIR
  fi

  a_datedir=$analARCDIR/$CDATE
  if [ ! -d $a_datedir ]; then 
     echo 'archive data does not exist'
     exit 2 
  else
     $NLN $a_datedir/pgbanl.${analCDUMP}.${CDATE}.grib2 $scraARCDIR/pgbanl.${fcstCDUMP}.${CDATE}.grib2
     #$NLN $a_datedir/pgbanl.${analCDUMP}.${CDATE}.grib2 $fcstARCDIR/pgbanl.${fcstCDUMP}.${CDATE}.grib2
  fi

  CDATE=`python $ndate $H_INT $CDATE`
done
