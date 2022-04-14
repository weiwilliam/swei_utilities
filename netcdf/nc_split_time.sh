#!/bin/ksh

#module purge
#module load intel
#module load nco
#module use -a /contrib/anaconda/modulefiles
#module load anaconda/latest
#module list

ndate="python $HOME/bin/ndate.py"
# Paths on Hera
#
#indir=/scratch1/BMC/wrf-chem/pagowski/MAPP_2018/MODEL/cams/pll
#outdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/MAPP/camstmp/pll
#indir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/MERRA2
#outdir=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/MERRA2

# Paths on Orion
#
#indir=/work/noaa/gsd-fv3-dev/pagowski/DATA/MODEL/m2/akbkll
#outdir=/work/noaa/gsd-fv3-dev/swei/common/m2
indir=/work/noaa/gsd-fv3-dev/pagowski/DATA/MODEL/camsira/pll_orig
outdir=/work/noaa/gsd-fv3-dev/swei/common/camsira

sdate=2016010100
edate=2016013100
inc_h=6 # time interval in nc file

cdate=$sdate
while [ $cdate -le $edate ];
do
  pdy=`echo $cdate | cut -c1-8`
  y4=`echo $cdate | cut -c1-4`
  mm=`echo $cdate | cut -c5-6`
  dd=`echo $cdate | cut -c7-8`
  #infile=$indir/cams_aeros_${pdy}_sdtotals.nc
  infile=$indir/cams_aods_${pdy}.nc
  #infile=$indir/MERRA2_400.inst3_2d_gas_Nx.${pdy}.nc4
  #infile=$indir/MERRA2_400.inst3_3d_aer_Nv.${pdy}.nc4
  tdate=$cdate
  #for t in 0 2 4 6 # MERRA2 AOD file is 3-hourly
  for t in 0 1 2 3 
  #for t in 0 1 2 3 4 5 6 7
  do
    echo "processing ${tdate}"
    hh=`echo $cdate | cut -c9-10`
    #outfile=$outdir/cams_aeros_${tdate}_sdtotals.nc
    outfile=$outdir/cams_aods_${tdate}.nc
    #outfile=$outdir/m2_aods_${tdate}.nc
    #outfile=$outdir/MERRA2_AOD.${tdate}.nc
    #outfile=$outdir/MERRA2_AER3D.${tdate}.nc
    ncks -d time,$t,$t $infile $outfile -3
    # comment out ncap2 for camsira data
    #ncap2 -s "time@units=\"minutes since ${y4}-${mm}-${dd} ${hh}:00:00\"" $outfile
    tdate=`$ndate $inc_h $tdate`
  done
  cdate=`$ndate 24 $cdate`
done

