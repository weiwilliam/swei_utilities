#!/bin/ksh
. $MODULESHOME/init/sh
module purge
module load contrib
#module load intel/2020
#module load intelpython3/2020
#module load met/9.1
#module load nco/4.8.1
#module load wgrib/2.0.8
#export MET_PATH="/apps/contrib/MET/9.1"
#export METPLUS_PATH="/apps/contrib/MET/METplus/METplus-3.1"
module load intel/2020.2
module load intelpython3/2020.2
#module load met/10.0.0
module load met/10.1.0
#module load nco/4.9.3
#module load wgrib/2.0.8
module use /apps/contrib/modulefiles
#module load metplus/4.0.0
module load metplus/4.1.0
export MET_PATH=/apps/contrib/MET/10.1.0/
#export MET_PATH=/apps/contrib/MET/10.0.0/
export METPLUS_PATH=/apps/contrib/MET/METplus/METplus-4.1.0
#export METPLUS_PATH=/apps/contrib/MET/METplus/METplus-4.0.0
export PATH=${PATH}:${METPLUS_PATH}/ush

