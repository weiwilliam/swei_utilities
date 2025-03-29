#!/bin/ksh
#
# Downloading the surface analysis weather map from WPC website
# Sample link
#   Radar image:
#     https://www.wpc.ncep.noaa.gov/archives/sfc/2020/radsfcus_exp2020082218.gif
#   Satellite IR Imagery:
#     https://www.wpc.ncep.noaa.gov/archives/sfc/2020/ussatsfc2020082218.gif
ndatepy='/home/swei/bin/ndate.py'

sdate=2020082200
edate=2020093018
hint=3

WPCarch='https://www.wpc.ncep.noaa.gov/archives/sfc'
#filetag='radsfcus_exp'
filetag='ussatsfc'
savedir='/data/users/swei/FTPdir/US_SatIR'

if [ ! -d $savedir ]; then
   mkdir -p $savedir
fi

cd $savedir

cdate=$sdate
while [[ $cdate -le $edate ]]
do
  echo $cdate
  yy=${cdate:0:4}
  filelink=$WPCarch/${yy}/${filetag}${cdate}.gif

  echo $filelink >> download_filelist.txt

  cdate=`python $ndatepy $hint $cdate`
done

if [ -s ./download_filelist.txt ]; then
   wget --input ./download_filelist.txt
fi
