#!/bin/bash -ax
#SBATCH --job-name=testrun
#SBATCH --time=00:15:00
#SBATCH --account=star
##SBATCH --partition=s4
##SBATCH --nodes=1
##SBATCH --cpus-per-task=1
##SBATCH --exclusive
#SBATCH --partition=serial
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=72000
#SBATCH --output=/data/users/swei/runlogs/sub_test_log.%j

source /usr/share/lmod/lmod/init/sh
module purge
module load license_intel/S4
module use /data/prod/hpc-stack/modulefiles/stack
module load hpc/1.1.0
module load hpc-intel/18.0.4
module load hpc-impi/18.0.4
module load zlib/1.2.11
module load png/1.6.35
module load jasper/2.0.25
module load w3nco/2.4.1
module load w3emc/2.9.2 
module load ip/3.3.3 
module load sp/2.3.3
module load bacio/2.4.1
module load g2/3.4.2
#module load netcdf/4.7.4
#module load hdf5/1.10.6
#module load wgrib2/2.0.8
#module load bufr/11.4.0
#module load gsl/2.6
#module load hdf/4.2.14
#module load hdfeos2/2.20
#module load g2c/1.6.2
#module load miniconda/3.8-s4
#module load grib_util/1.2.2
#module load prod_util/1.2.1
#module load nco/4.9.3

CNVGRIB_EXE=/data/users/swei/Git/grib_util/bin/cnvgrib
cd /scratch/users/swei/test
#$CNVGRIB_EXE -g21 /data/users/swei/archive/hazyda_ctrl_fcst/2020061006/pgbf168.gfs.2020061006.grib2 ./test.grib
$CNVGRIB_EXE -g21 /scratch/users/swei/archive/UFS_SMOKE_RR/pgbf168.gfs.2020091800.grib2 ./test.grib
