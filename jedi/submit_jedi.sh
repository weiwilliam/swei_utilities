#!/usr/bin/bash
#SBATCH --job-name=swei_jedi
#SBATCH --nodes=1
##SBATCH --ntasks=6
##SBATCH --cpus-per-task=1
#SBATCH --account=da-cpu
#SBATCH --partition=orion
#SBATCH --qos=debug
##SBATCH --qos=batch
#SBATCH --time=0:30:00
#SBATCH --output=/work2/noaa/jcsda/shihwei/slurmlogs/testjedi.%j

#Information of Orion
#https://intranet.hpc.msstate.edu/helpdesk/resource-docs/orion_guide.php

set -x

source /etc/bashrc
source /home/shihwei/.bashrc
load_skylab
module list

bundle_dir=${JEDI_ROOT}/jedi-bundle
builds_dir=${JEDI_ROOT}/build

bin_path=$builds_dir/bin
exe='fv3jedi_converttolatlon.x'
JEDIEXEC=$bin_path/$exe

output_path='/work2/noaa/jcsda/shihwei/model/geos_latlon/'
input_yaml=$output_path/yamls/convert.latlon.geos.yaml

workdir=$output_path/workdir
if [ ! -d $workdir ]; then
    mkdir -p $workdir
else
    rm -rf $workdir/*
fi

cd $workdir
srun $JEDIEXEC --no-validate $input_yaml 2> stderr.$$.log 1> stdout.$$.log

exit 0
