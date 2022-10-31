#!/usr/bin/bash
#SBATCH --job-name=swei_jedi_ctest
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=1:00:00
#SBATCH --output=/data/users/swei/runlogs/jedi_ctest.%j.log
##SBATCH --mail-user=<email-address>

source /etc/bashrc
module purge
module use /data/prod/jedi/spack-stack/modulefiles
module load miniconda/3.9.12
module load ecflow/5.8.4
module use /data/prod/jedi/spack-stack/spack-stack-v1/envs/skylab-2.0.0-intel-2021.5.0/install/modulefiles/Core
module load stack-intel/2021.5.0
module load stack-intel-oneapi-mpi/2021.5.0
module load stack-python/3.9.12
module unuse /opt/apps/modulefiles/Compiler/intel/non-default/22
module unuse /opt/apps/modulefiles/Compiler/intel/22
module load jedi-fv3-env/1.0.0
module load jedi-ewok-env/1.0.0
module load soca-env/1.0.0
module load sp/2.3.3

source /home/swei/.conda-source
module list
ulimit -s unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

builds_dir=/data/users/swei/Builds/jedi_fv3

cd $builds_dir
#ctest -E get_ --rerun-failed --output-on-failure
ctest -E get_

exit 0
