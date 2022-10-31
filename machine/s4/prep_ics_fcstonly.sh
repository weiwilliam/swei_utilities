#!/bin/ksh

ndate=/home/swei/bin/ndate.py
fcstonly_expname='hazyda_aerov6_fcst'
archive_expname='hazyda_aerov6'
CDUMP='gfs'
ARCDUMP='gdas'
rDUMP=$ARCDUMP

ROTDIR=/scratch/users/swei/comrot/${fcstonly_expname}
ARCDIR=/data/users/swei/archive/${archive_expname}

SDATE=2020061000
EDATE=2020071000
H_INT=24

CDATE=$SDATE
while [ $CDATE -le $EDATE ]
do
  GDATE=`python $ndate -6 $CDATE`
  cPDY=${CDATE:0:8}; cCYC=${CDATE:8:2}
  gPDY=${GDATE:0:8}; gCYC=${GDATE:8:2}

  memdir=$ROTDIR/${CDUMP}.${cPDY}/${cCYC}/atmos/
  if [ ! -d $memdir ]; then mkdir -p $memdir; fi
  if [ ! -d $memdir/RESTART ]; then
     cp -r $ARCDIR/$CDATE/RESTART $memdir
  fi
  cp $ARCDIR/$CDATE/${ARCDUMP}.t${cCYC}z.atminc.nc \
     $memdir/${CDUMP}.t${cCYC}z.atminc.nc
  cp $ARCDIR/$CDATE/${ARCDUMP}.t${cCYC}z.atmi003.nc \
     $memdir/${CDUMP}.t${cCYC}z.atmi003.nc
  cp $ARCDIR/$CDATE/${ARCDUMP}.t${cCYC}z.atmi009.nc \
     $memdir/${CDUMP}.t${cCYC}z.atmi009.nc

  gmemdir=$ROTDIR/${rDUMP}.${gPDY}/${gCYC}/atmos/
  if [ ! -d $gmemdir ]; then mkdir -p $gmemdir; fi
  if [ ! -d $gmemdir/RESTART ]; then
     cp -r $ARCDIR/$GDATE/RESTART $gmemdir
  fi

  CDATE=`python $ndate $H_INT $CDATE`
done
