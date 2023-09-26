#!/usr/bin/bash
#SBATCH --job-name=swei_jedi
#SBATCH --nodes=1
##SBATCH --ntasks=12
##SBATCH --cpus-per-task=1
#SBATCH --account=jcsda
#SBATCH --partition=orion
#SBATCH --qos=batch
#SBATCH --time=2:30:00
#SBATCH --output=/work2/noaa/jcsda/swei/slurmlogs/jedi_build.%j

set -x

source /etc/bashrc
source /home/swei/.bash_profile
load_skylab
module list

DO_ECBUILD='N'
DO_MAKE='Y'
DO_TEST='N' # run "ctest -R get_" before do whole ctest
DO_RERUN='N'
bundle_dir=${JEDI_ROOT}/jedi-bundle
builds_dir=${JEDI_ROOT}/build
#bundle_dir=/data/users/swei/Git/JEDI/ioda-bundle
#builds_dir=/data/users/swei/Builds/jedi-ioda
#bundle_dir=/data/users/swei/Git/JEDI/fv3-bundle
#builds_dir=/data/users/swei/Builds/jedi-fv3

testname="fv3jedi_test_tier1_forecast_fv3lm"

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
