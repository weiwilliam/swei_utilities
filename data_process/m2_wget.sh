#!/usr/bin/env bash

M2_srclink='https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2'
file_cat='M2I3NVAER.5.12.4'
file_tag='inst3_3d_aer_Nv'

desdir=/glade/derecho/scratch/swei/Dataset/input/bkg/MERRA-2

sdate=2024110100
edate=2024110100

func_ndate (){
    hrinc=$1
    syear=${2:0:4}
    smon=${2:4:2}
    sday=${2:6:2}
    shr=${2:8:2}

    datein=`date -u --date="$smon/$sday/$syear $shr:00:00"`
    dateout=`date +%Y%m%d%H -u -d "$datein $hrinc hours"`
    echo $dateout
}

cdate=$sdate
while [ $cdate -le $edate ];
do
  y4=`echo $cdate | cut -c1-4`
  m2=`echo $cdate | cut -c5-6`
  pdy=`echo $cdate | cut -c1-8`
  filelink=$M2_srclink/$file_cat/$y4/$m2/MERRA2_400.${file_tag}.${pdy}.nc4

  if [ ! -d $desdir/$y4/$m2 ]; then
     mkdir -p $desdir/$y4/$m2
  fi

  cd $desdir/$y4/$m2

  wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --auth-no-challenge=on --keep-session-cookies --content-disposition $filelink

  cdate=`func_ndate 24 $cdate`
done
