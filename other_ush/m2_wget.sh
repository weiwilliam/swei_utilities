#!/bin/ksh -x 
module purge
module load miniconda/3.8-s4

ndate="python $HOME/bin/ndate.py"

M2_srclink='https://goldsmr5.gesdisc.eosdis.nasa.gov/data/MERRA2'
file_cat='M2I3NVAER.5.12.4'
file_tag='inst3_3d_aer_Nv'

desdir=/data/users/swei/common/MERRA2

sdate=2020061000
edate=2020062100

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

  cdate=`$ndate 24 $cdate`
done
