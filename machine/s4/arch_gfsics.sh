#!/bin/ksh

machine='s4'
ndatepy='/home/swei/bin/ndate.py'

expname='hazyda_ctrl'
comdir='/scratch/users/swei/comrot'
archdir='/data/users/swei/archive'
missinglog=$archdir/$expname/missing_log

sdate=2020070100
edate=2020071018

cdate=$sdate
while [[ $cdate -le $edate ]];
do
  pdy=${cdate:0:8}; echo $pdy
  cyc=${cdate:8:2}; echo $cyc

  echo "check $archdir/$expname/$cdate/RESTART"
  if [ ! -d $archdir/$expname/$cdate/RESTART ]; then
     echo "RESTART is not archived"
     if [ -d $comdir/$expname/gdas.$pdy/$cyc/atmos/RESTART ]; then
        if [ `ls $comdir/$expname/gdas.$pdy/$cyc/atmos/RESTART | wc -l` -eq 0 ]; then
           echo "$cdate RESTART is missing" >> $missinglog
        else 
           cp -r $comdir/$expname/gdas.$pdy/$cyc/atmos/RESTART \
                 $archdir/$expname/$cdate/RESTART
        fi
     else
        echo "$cdate RESTART is missing" >> $missinglog
     fi
  fi

  inc3=gdas.t${cyc}z.atmi003.nc
  echo "check $archdir/$expname/$cdate/$inc3"
  if [ ! -s $archdir/$expname/$cdate/$inc3 ]; then
     echo "inc3 is not archived"
     if [ -s $comdir/$expname/gdas.$pdy/$cyc/atmos/$inc3 ]; then
        cp $comdir/$expname/gdas.$pdy/$cyc/atmos/$inc3 \
           $archdir/$expname/$cdate/$inc3
     else
        echo "$cdate inc3 is missing" >> $missinglog
     fi 
  fi

  inc=gdas.t${cyc}z.atminc.nc
  echo "check $archdir/$expname/$cdate/$inc"
  if [ ! -s $archdir/$expname/$cdate/$inc ]; then
     echo "inc is not archived"
     if [ -s $comdir/$expname/gdas.$pdy/$cyc/atmos/$inc ]; then
        cp $comdir/$expname/gdas.$pdy/$cyc/atmos/$inc \
           $archdir/$expname/$cdate/$inc
     else
        echo "$cdate inc is missing" >> $missinglog
     fi 
  fi

  inc9=gdas.t${cyc}z.atmi009.nc
  echo "check $archdir/$expname/$cdate/$inc9"
  if [ ! -s $archdir/$expname/$cdate/$inc9 ]; then
     echo "inc9 is not archived"
     if [ -s $comdir/$expname/gdas.$pdy/$cyc/atmos/$inc9 ]; then
        cp $comdir/$expname/gdas.$pdy/$cyc/atmos/$inc9 \
           $archdir/$expname/$cdate/$inc9
     else
        echo "$cdate inc9 is missing" >> $missinglog
     fi 
  fi

  cdate=`python $ndatepy 6 $cdate`
done
