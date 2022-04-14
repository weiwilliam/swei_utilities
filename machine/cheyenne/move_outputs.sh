#!/bin/ksh

machine='cheyenne'
ndatepy='/glade/u/home/swei/bin/ndate.py'

expname='UFS_SMOKE'
subprefix='ufs.mfu0'
comdir='/glade/scratch/clu'
archdir='/glade/scratch/swei'

sdate=2020091900
edate=2020092100
hint=24

cdate=$sdate
while [[ $cdate -le $edate ]];
do
  pdy=${cdate:0:8}; echo $pdy
  cyc=${cdate:8:2}; echo $cyc

  echo "check $archdir/$expname/${subprefix}.${cdate}"
  if [ ! -d $archdir/$expname/${subprefix}.${cdate} ]; then
     mkdir -p $archdir/$expname/${subprefix}.${cdate}
     if [ -s $comdir/$expname/${subprefix}.${cdate} ]; then
        cp $comdir/$expname/${subprefix}.${cdate}/dynf*.nc \
           $archdir/$expname/${subprefix}.${cdate}
        cp $comdir/$expname/${subprefix}.${cdate}/phyf*.nc \
           $archdir/$expname/${subprefix}.${cdate}
        cp $comdir/$expname/${subprefix}.${cdate}/atmos_4xdaily.tile?.nc \
           $archdir/$expname/${subprefix}.${cdate}
     fi
  fi

#  for ((i=1; i<=$num_mem; i++));
#  do
#    mem_char=$(printf %03i $i)
#    ensfcst=gdas.t${cyc}z.atmf006.nc
#    echo "check $archdir/$expname/$cdate/enkf/mem$mem_char/$ensfcst"
#    if [ ! -s $archdir/$expname/$cdate/enkf/mem$mem_char/$ensfcst ]; then
#       echo "fcst mem$mem_char not archived"
#       if [ -s $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/mem$mem_char/$ensfcst ]; then      
#          cp $comdir/$expname/enkfgdas.$pdy/$cyc/atmos/mem$mem_char/$ensfcst \
#             $archdir/$expname/$cdate/enkf/mem$mem_char/$ensfcst
#       fi
#    fi
#  done

  cdate=`python $ndatepy $hint $cdate`
done
