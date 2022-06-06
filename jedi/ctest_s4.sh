#!/usr/bin/bash
#SBATCH --job-name=swei_jedi_ctest
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:20:00
#SBATCH --output=/data/users/swei/runlogs/jedi_ctest.%j.log
##SBATCH --mail-user=<email-address>

source /etc/bashrc
module purge
export JEDI_OPT=/data/prod/jedi/opt/modules
module use $JEDI_OPT/modulefiles/core
module load jedi/intel-impi
source /home/swei/.conda-source
module list
ulimit -s unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

builds_dir=/data/users/swei/Builds/jedi_ioda

cd $builds_dir
ctest -E get_ --rerun-failed --output-on-failure
#ctest -E get_

exit 0
