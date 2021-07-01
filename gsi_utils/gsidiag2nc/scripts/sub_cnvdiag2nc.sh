#!/bin/ksh -ax
#SBATCH --job-name=cnvdiag2nc
#SBATCH --partition=serial
#SBATCH --time=03:00:00
#SBATCH --account=star
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6000
#SBATCH --output=/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts/log/log.%j

path=/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts
export HDF5_USE_FILE_LOCKING=FALSE

python3 $path/0_cnvdiag2nc_rev.py
