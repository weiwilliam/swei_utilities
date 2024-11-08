#!/usr/bin/bash
#SBATCH --job-name=swei_jedi_ctest
#SBATCH --nodes=1
##SBATCH --cpus-per-task=24
#SBATCH --time=2:00:00
#SBATCH --output=/data/users/swei/runlogs/jedi_build.%j.log
##SBATCH --mail-user=<email-address>

set -x

DO_ECBUILD='N'
DO_MAKE='Y'
DO_TEST='N' # run "ctest -R get_" before do whole ctest
DO_RERUN='N'
#bundle_dir=/data/users/swei/Git/JEDI/JEDI-METplus/genint-bundle
#builds_dir=/data/users/swei/Git/JEDI/JEDI-METplus/genint-bundle/build
#bundle_dir=/data/users/swei/Git/JEDI/qxx-genint
#builds_dir=/data/users/swei/Git/JEDI/qxx-genint/build
bundle_dir=/data/users/swei/Git/skylab/jedi-bundle
builds_dir=/data/users/swei/Git/skylab/build

testname="genint_*"

ulimit -s unlimited || true
ulimit -v unlimited || true

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

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
