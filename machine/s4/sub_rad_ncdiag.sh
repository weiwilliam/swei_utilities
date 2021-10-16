#!/bin/ksh -ax
#SBATCH --job-name=rad_ncdiag
#SBATCH --partition=serial
#SBATCH --time=00:30:00
#SBATCH --account=star
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6000
#SBATCH --output=/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts/log/log.%j

source /etc/bashrc
module load license_intel
module load intel

export HDF5_USE_FILE_LOCKING='FALSE'
path=/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts
python3 $path/0_raddiag2nc.py
