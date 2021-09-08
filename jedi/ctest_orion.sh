#!/usr/bin/bash
#SBATCH --job-name=swei_ctest_jedi
##SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --account=gsd-fv3-dev
#SBATCH --partition=debug
#SBATCH --qos=debug
#SBATCH --time=0:30:00
#SBATCH --mail-user=swei@albany.edu

source /etc/bashrc
module purge
export JEDI_OPT=/work/noaa/da/grubin/opt/modules
module use $JEDI_OPT/modulefiles/core
module load jedi/intel-impi
module list
ulimit -s unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

cd /work/noaa/gsd-fv3-dev/swei/jedi/build
ctest -E get_

exit 0
