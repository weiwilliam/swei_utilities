#!/usr/bin/env bash
#PBS -N jedi_ctest
#PBS -A NMMM0072
##PBS -A UALB0028
#PBS -q develop
#PBS -l job_priority=economy
#PBS -l select=1:ncpus=12:mem=128GB
#PBS -l walltime=02:00:00
#PBS -o ./jedi_ctest_log.out
#PBS -e ./jedi_ctest_log.err

set -x

DO_ECBUILD='N'
DO_MAKE='Y'
DO_TEST='N' # run "ctest -R get_" before do whole ctest
DO_RERUN='N'
bundle_dir=/glade/work/swei/Git/JEDI-METplus/genint-bundle
builds_dir=/glade/work/swei/Git/JEDI-METplus/genint-bundle/build2
#bundle_dir=/glade/work/swei/skylab/jedi-bundle
#builds_dir=/glade/work/swei/skylab/build2

testname="genint_*"

ulimit -s unlimited || true
ulimit -v unlimited || true
export HDF5_USE_FILE_LOCKING=FALSE

cd $builds_dir
[[ $DO_ECBUILD == 'Y' ]]&& ecbuild $bundle_dir
[[ $DO_MAKE == 'Y' ]]&& make VERBOSE=1 -j 12
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
