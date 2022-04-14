#!/bin/ksh
ndate=/home/swei/bin/ndate.py
archive_expname='hazyda_ctrl'
CDUMP='gdas'

ARCDIR=/data/users/swei/archive/${archive_expname}
TMPDIR=/scratch/users/swei/ncdiag
WRKDIR=$TMPDIR/wrk
DESDIR=$TMPDIR/$archive_expname

untar_sensor='iasi'

if [ ! -d $WRKDIR ];then
   mkdir -p $WRKDIR
else
   rm $WRKDIR/*
fi

SDATE=2020081306
EDATE=2020092118

CDATE=$SDATE
while [ $CDATE -le $EDATE ]
do
  cd $WRKDIR
  if [ ! -d ${DESDIR}/${CDATE} ]; then
     mkdir -p ${DESDIR}/${CDATE}
  fi
  cnvtar_file=$ARCDIR/$CDATE/cnvstat.${CDUMP}.${CDATE}
  #cp $cnvtar_file $WRKDIR
  tar -xvf $cnvtar_file
  rc=$?
  if [ $rc -eq 0 ]; then
     gunzip *.gz
     mv diag_*.nc4 $DESDIR/$CDATE
  else
     echo 'untar failed for cnvstat file'
     exit 1
  fi

  radtar_file=$ARCDIR/$CDATE/radstat.${CDUMP}.${CDATE}
  #cp $radtar_file $WRKDIR
  tar -xvf $radtar_file *${untar_sensor}*
  rc=$?
  if [ $rc -eq 0 ]; then
     gunzip *.gz
     mv diag_*.nc4 $DESDIR/$CDATE
  else
     echo 'untar failed for radstat file'
     exit 2
  fi  

  CDATE=`python $ndate 6 $CDATE`
done
