#!/bin/ksh
module load intel/19.1.1
module load grib-bins/1.3

WGRIB2=`which wgrib2`
ndate=${HOME}/bin/ndate.py

exp=UFS_SMOKE_RR
subdir_prefix='ufs.mfu6'
dump=gfs
archpath=/glade/scratch/dfgrogan/UFS_Stand/SMOKE
inputpath=$archpath/$exp
outputpath=/glade/scratch/swei/GRIB2OUT/$exp

sdate=2020082200
edate=2020082200
FHMAX=168
FHINC=6

# new_grid arguments
# latlon 0:1440:0.25 90:721:-0.25
# latlon 0:360:1.0 90:181:-1.0
# latlon 0:720:0.5 90:361:-0.5

cdate=$sdate
while [ $cdate -le $edate ]; do
   cdate_inputpath=$inputpath/${subdir_prefix}.${cdate}
   cdate_outputpath=$outputpath/$cdate
   [[ ! -d $cdate_outputpath ]] && mkdir -p $cdate_outputpath
   for ((fhr=0;fhr<=${FHMAX};fhr+=${FHINC}))
   do
     if [ $fhr -lt 100 ]; then
        o_fhrstr=$(printf %02i $fhr)
     else
        o_fhrstr=$(printf %03i $fhr)
     fi
     fhrstr=$(printf %03i $fhr)
     infile=$cdate_inputpath/GFSPRS.$fhrstr
     outfile=$cdate_outputpath/pgbf${o_fhrstr}.${dump}.${cdate}.grib2
      
$WGRIB2 -ncpu 1 $infile -set_grib_type same -new_grid_winds earth -new_grid_interpolation bilinear -if ':(CSNOW|CRAIN|CFRZR|CICEP|ICSEV):' -new_grid_interpolation neighbor -fi -set_bitmap 1 -set_grib_max_bits 16 -if ':(APCP|ACPCP|PRATE|CPRAT):' -set_grib_max_bits 25 -fi -if ':(APCP|ACPCP|PRATE|CPRAT|DZDT):' -new_grid_interpolation budget -fi -new_grid latlon 0:360:1.0 90:181:-1.0 $outfile

   done
   cdate=`python $ndate 24 $cdate`
done
