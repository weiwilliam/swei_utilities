#!/usr/bin/bash
#SBATCH --job-name=swei_jedi
#SBATCH --nodes=1
#SBATCH --ntasks=12
##SBATCH --cpus-per-task=1
#SBATCH --account=da-cpu
#SBATCH --partition=hercules
#SBATCH --qos=batch
#SBATCH --time=2:30:00
#SBATCH --output=/work2/noaa/jcsda/shihwei/slurmlogs/jedi_build.%j

#Information of Orion
#https://intranet.hpc.msstate.edu/helpdesk/resource-docs/orion_guide.php

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

ulimit -s unlimited || true
ulimit -v unlimited || true

set -x

DO_ECBUILD='N'
DO_MAKE='Y'
DO_TEST='N' # run "ctest -R get_" before do whole ctest
DO_RERUN='N'
bundle_dir=${JEDI_ROOT}/jedi-bundle
builds_dir=${JEDI_ROOT}/build_hercules_gnu

testname="quenchxx_test_genint_*"
#testname="fv3jedi_test_tier1_forecast_fv3lm"

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
