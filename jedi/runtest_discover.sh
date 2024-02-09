#!/usr/bin/sh
#SBATCH --job-name=swei_jedi_ctest
##SBATCH --nodes=1
#SBATCH --ntasks=6
##SBATCH --cpus-per-task=24
#SBATCH --time=2:00:00
#SBATCH --output=/discover/nobackup/swei1/runlogs/jedi_build.%j.log
##SBATCH --mail-user=<email-address>
export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

ulimit -s unlimited
ulimit -v unlimited

set -x

DO_ECBUILD='N'
DO_MAKE='N'
DO_TEST='Y' # run "ctest -R get_" before do whole ctest
DO_RERUN='N'
bundle_dir=${JEDI_ROOT}/jedi-bundle
builds_dir=${JEDI_ROOT}/build
#bundle_dir=/data/users/swei/Git/JEDI/ioda-bundle
#builds_dir=/data/users/swei/Builds/jedi-ioda
#bundle_dir=/data/users/swei/Git/JEDI/fv3-bundle
#builds_dir=/data/users/swei/Builds/jedi-fv3

#testname="fv3jedi_test_tier1_forecast_fv3lm"


cd $builds_dir
[[ $DO_ECBUILD == 'Y' ]]&& ecbuild $bundle_dir
[[ $DO_MAKE == 'Y' ]]&& make VERBOSE=1 -j 8
if [ $DO_TEST == 'Y' ]; then
    if [ -z $testname ]; then
        if [ $DO_RERUN == 'Y' ]; then
            ctest -E get_ --rerun-failed --output-on-failure
        else
            ctest -E get_ 
        fi
    else
        ctest -VV -R $testname
    fi
fi
#ctest -V -R hofx_save_geovals

exit 0
