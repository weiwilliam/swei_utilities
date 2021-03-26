#!/bin/ksh

module purge
module load intel
module load impi
module load netcdf
module load nco
module use -a /contrib/anaconda/modulefiles
module load anaconda/latest
module list

ndate="python $HOME/bin/ndate.py"
m2tofv3='/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/util/m2tofv3chem.fd/m2tofv3chem.x'
indir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/MERRA2
outdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/MERRA2

sdate=2020062200
edate=2020062200

cdate=$sdate
while [ $cdate -le $edate ];
do
  pdy=`echo $cdate | cut -c1-8`
  y4=`echo $cdate | cut -c1-4`
  mm=`echo $cdate | cut -c5-6`
  dd=`echo $cdate | cut -c7-8`
  infile=$indir/$y4/$mm/MERRA2_400.inst3_3d_aer_Nv.${pdy}.nc4
  tdate=$cdate
  #for t in 0 2 4 6 # MERRA2 AOD file is 3-hourly
  #for t in 0 1 2 3 
  for t in 0 1 2 3 4 5 6 7
  do
    echo "processing ${tdate}"
    hh=`echo $cdate | cut -c9-10`
    outfile=$outdir/$y4/$mm/MERRA2_AER3D.${tdate}.nc
    m2l64file=$outdir/$y4/$mm/MERRA2_AER3D_FV3L64.v2.${tdate}.nc
    #ncks -d time,$t,$t $infile $outfile
    $m2tofv3 $outfile $m2l64file
    tdate=`$ndate 3 $tdate`
  done
  cdate=`$ndate 24 $cdate`
done

