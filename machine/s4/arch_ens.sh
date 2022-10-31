#!/bin/ksh

machine='s4'
ndatepy='/home/swei/bin/ndate.py'

expname='hazyda_aerov6'
comdir='/scratch/users/swei/comrot'
archdir='/data/users/swei/archive'
num_mem=60

sdate=2020060100
edate=2020071018

cdate=$sdate
while [[ $cdate -le $edate ]];
do
  pdy=${cdate:0:8}; echo $pdy
  cyc=${cdate:8:2}; echo $cyc

  anl_ensres=gdas.t${cyc}z.atmanl.ensres.nc
  echo "check $archdir/$expname/$cdate/$anl_ensres"
  if [ ! -s $archdir/$expname/$cdate/$anl_ensres ]; then
     echo "anl in ensres not archived"
     if [ -s $comdir/$expname/gdas.$pdy/$cyc/atmos/$anl_ensres ]; then
        cp $comdir/$expname/gdas.$pdy/$cyc/atmos/$anl_ensres \
           $archdir/$expname/$cdate/$anl_ensres
     fi
  fi

  ensmean=gdas.t${cyc}z.atmf006.ensmean.nc
  echo "check $archdir/$expname/$cdate/enkf/$ensmean"
  if [ ! -s $archdir/$expname/$cdate/enkf/$ensmean ]; then
     echo "ens mean not archived"
     if [ -s $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/$ensmean ]; then
        cp $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/$ensmean \
           $archdir/$expname/$cdate/enkf/$ensmean
     fi 
  fi

  enssprd=gdas.t${cyc}z.atmf006.ensspread.nc
  echo "check $archdir/$expname/$cdate/enkf/$enssprd"
  if [ ! -s $archdir/$expname/$cdate/enkf/$enssprd ]; then
     echo "ens spread not archived"
     if [ -s $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/$enssprd ]; then
        cp $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/$enssprd \
           $archdir/$expname/$cdate/enkf/$enssprd
     fi
  fi

  for ((i=1; i<=$num_mem; i++));
  do
    mem_char=$(printf %03i $i)
    ensfcst=gdas.t${cyc}z.atmf006.nc
    echo "check $archdir/$expname/$cdate/enkf/mem$mem_char/$ensfcst"
    if [ ! -s $archdir/$expname/$cdate/enkf/mem$mem_char/$ensfcst ]; then
       echo "fcst mem$mem_char not archived"
       if [ -s $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/mem$mem_char/$ensfcst ]; then      
          cp $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/mem$mem_char/$ensfcst \
             $archdir/$expname/$cdate/enkf/mem$mem_char/$ensfcst
       fi
    fi
  done

  cdate=`python $ndatepy 6 $cdate`
done
