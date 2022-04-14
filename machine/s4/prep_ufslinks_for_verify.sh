#!/bin/ksh

NLN="/bin/ln -sf"
ndate=/home/swei/bin/ndate.py
archive_expname="UFS_SMOKE_RR"
subfix='ufs.mfu6'
fcstCDUMP='gfs'
fileprefix='GFSPRS'

fcstARCDIR=/data/users/swei/archive/${archive_expname}
scraARCDIR=/scratch/users/swei/archive/${archive_expname}
if [ ! -d $scraARCDIR ]; then
   mkdir -p $scraARCDIR
fi

SDATE=2020082200
EDATE=2020082200
H_INT=24
FHMAX=168
FHINC=6

CDATE=$SDATE
while [ $CDATE -le $EDATE ]
do
  f_datedir=$fcstARCDIR/${subfix}.${CDATE}
  
  if [ ! -d $f_datedir ]; then 
     echo 'archive data does not exist'
     exit 2 
  else
     for ((fhr=0;fhr<=${FHMAX};fhr+=${FHINC}))
     do
       if [ $fhr -lt 100 ]; then
          o_fhrstr=$(printf %02i $fhr)
       else
          o_fhrstr=$(printf %03i $fhr)
       fi
       fhrstr=$(printf %03i $fhr)
       $NLN $f_datedir/${fileprefix}.${fhrstr} $scraARCDIR/pgbf${o_fhrstr}.${fcstCDUMP}.${CDATE}.grib2
       #$NLN $f_datedir/*grib2 $fcstARCDIR
     done
  fi

  CDATE=`python $ndate $H_INT $CDATE`
done
