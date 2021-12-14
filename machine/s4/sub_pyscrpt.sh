#!/bin/ksh -ax
#SBATCH --job-name=run_pyscripts
#SBATCH --partition=serial
#SBATCH --time=08:00:00
#SBATCH --account=star
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6000
#SBATCH --output=/data/users/swei/tmp/log.%j

source /etc/bashrc
module load license_intel
module load intel

export HDF5_USE_FILE_LOCKING='FALSE'
pyscript=/home/swei/research/pyscripts/create_ncens_rmse_spread.py
python3 $pyscript
