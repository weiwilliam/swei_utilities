#!/usr/bin/bash
#SBATCH --job-name=swei_compile
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=2:00:00
#SBATCH --output=/data/users/swei/runlogs/compile.%j.log
##SBATCH --mail-user=<email-address>

DO_COMP='Y'
builds_dir=/data/users/swei/Git/JEDI/gefs-aerosol/wfm/sorc/
builds_scrpt=$builds_dir/build_fv3_ccpp_chem.sh
builds_log=$builds_dir/build-fv3_ccpp_chem.log

source /etc/bashrc
source /home/swei/.bash_profile
ulimit -s unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

cd $builds_dir
[[ $DO_COMP == 'Y' ]]&& $builds_scrpt 2>&1 | tee $builds_log

exit 0
