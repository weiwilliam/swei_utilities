#!/bin/ksh -ax
#SBATCH --job-name=rad_diag2nc
#SBATCH --time=00:30:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=6000
#### Hera
#SBATCH --account=gsd-fv3-dev
#SBATCH --partition=service
#SBATCH --qos=debug
#SBATCH --output=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/AeroObsStats/logs/log.%j
#### S4
##SBATCH --partition=serial
##SBATCH --account=star
##SBATCH --output=/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts/log/log.%j

export machine='hera'
export HDF5_USE_FILE_LOCKING='FALSE'

source /etc/bashrc
if [ $machine == 's4' ]; then
   module load license_intel
   module load intel
   path=/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts
elif [ $machine == 'hera' ]; then
   module load intel
   module use -a /contrib/anaconda/modulefiles
   module load anaconda/latest
   path=/home/Shih-wei.Wei/utils/gsi_utils/gsidiag2nc/pyscript
fi
module list

if [ ! -s /home/Shih-wei.Wei/utils/gsi_utils/gsidiag2nc/src ];then
   echo 'lib path is not existed!'
fi

python3 $path/0_raddiag2nc.py
#python3 $path/test.py
