#!/bin/ksh
. $MODULESHOME/init/sh
module purge
module load contrib
module load intel/2020
module load intelpython3/2020
module load met/9.1
module load nco/4.8.1
module load wgrib/2.0.8
export MET_PATH="/apps/contrib/MET/9.1"
export METPLUS_PATH="/apps/contrib/MET/METplus/METplus-3.1"
export PATH=${PATH}:${METPLUS_PATH}/ush

