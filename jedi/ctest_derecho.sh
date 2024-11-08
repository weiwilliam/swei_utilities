#!/usr/bin/env bash
#PBS -N jedi_ctest
#PBS -A UALB0044
#PBS -q main
#PBS -l job_priority=economy
#PBS -l select=1:ncpus=8
#PBS -l walltime=02:00:00
#PBS -j oe
#PBS -o /glade/work/swei/runlogs/jedi_ctest.log.%j

set -x

DO_ECBUILD='N'
DO_MAKE='Y'
DO_TEST='N' # run "ctest -R get_" before do whole ctest
DO_RERUN='N'
bundle_dir=/glade/work/swei/Git/JEDI-METplus/genint-bundle
builds_dir=/glade/work/swei/Git/JEDI-METplus/genint-bundle/build
#bundle_dir=/data/users/swei/Git/skylab/jedi-bundle
#builds_dir=/data/users/swei/Git/skylab/build
#bundle_dir=/data/users/swei/Git/JEDI/ioda-bundle
#builds_dir=/data/users/swei/Builds/jedi-ioda
#bundle_dir=/data/users/swei/Git/JEDI/fv3-bundle
#builds_dir=/data/users/swei/Builds/jedi-fv3

testname="genint_*"

ulimit -s unlimited || true
ulimit -v unlimited || true
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
