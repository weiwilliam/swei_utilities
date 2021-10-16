#!/bin/ksh -ax
#SBATCH --job-name=runpython
#SBATCH --time=00:30:00
#SBATCH --account=gsd-fv3-dev
#SBATCH --qos=debug
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6000
#SBATCH --output=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrklog/runpython.log.%j

. /apps/lmod/lmod/init/sh
module load intel/18.0.5.274 
module load anaconda/latest

export HDF5_USE_FILE_LOCKING='FALSE'
pyscript=/home/Shih-wei.Wei/research/pyscripts/ncrad_newQC_stats.py
python3 $pyscript
