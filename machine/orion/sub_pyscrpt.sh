#!/usr/bin/bash
#SBATCH --job-name=swei_runpy
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=1:30:00
#SBATCH --account=da-cpu
#SBATCH --partition=orion
#SBATCH --qos=batch
#SBATCH --output=/work2/noaa/jcsda/shihwei/slurmlogs/runpy.log.%j

#Information of Orion
#https://intranet.hpc.msstate.edu/helpdesk/resource-docs/orion_guide.php

set -x

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING='FALSE'

running_under=/work2/noaa/jcsda/shihwei/data/viirs_j1_l1b
pyscript="/work2/noaa/jcsda/shihwei/git/ioda-bundle/iodaconv/src/compo/viirs_l1bnc2ioda.py -i VJ102MOD/2021/217/VJ102MOD.A2021217.0[3-8]* -g VJ103MOD/2021/217/VJ103MOD.A2021217.0[3-8]* -n 0.995 -o multifiles_test.nc"

cd $running_under

echo "$(date) Running: $pyscript"
  python $pyscript
echo "$(date) End: $pyscript"
