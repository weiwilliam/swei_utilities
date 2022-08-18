#!/usr/bin/bash
#SBATCH --job-name=swei_ctest_jedi
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --account=gsd-fv3-dev
#SBATCH --partition=orion
#SBATCH --qos=batch
#SBATCH --time=1:30:00
#SBATCH --output=/work2/noaa/gsd-fv3-dev/swei/slurmlogs/ctest.%j

source /etc/bashrc
module purge
module use /work/noaa/da/jedipara/spack-stack/modulefiles
module load miniconda/3.9.7
module use /work/noaa/da/role-da/spack-stack/spack-stack-v1/envs/skylab-1.0.0-intel-2022.0.2/install/modulefiles/Core
module load stack-intel/2022.0.2
module load stack-intel-oneapi-mpi/2021.5.1
module load stack-python/3.9.7
module load jedi-fv3-env/1.0.0
module load jedi-ewok-env/1.0.0
module load nco/5.0.6
module list

ulimit -s unlimited
ulimit -v unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

cd /work/noaa/gsd-fv3-dev/swei/builds/jedi-fv3
ctest -E get_

exit 0
