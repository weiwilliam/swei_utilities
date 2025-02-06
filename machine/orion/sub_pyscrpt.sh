#!/usr/bin/bash
#SBATCH --job-name=swei_runpy
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=1:30:00
#SBATCH --account=da-cpu
#SBATCH --partition=orion
#SBATCH --qos=batch
#SBATCH --exclusive
#SBATCH --output=/work2/noaa/jcsda/shihwei/slurmlogs/runpy.log.%j

#Information of Orion
#https://intranet.hpc.msstate.edu/helpdesk/resource-docs/orion_guide.php

set -x

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING='FALSE'

bundledir=/work2/noaa/jcsda/shihwei/skylab/jedi-bundle
running_under=/work2/noaa/jcsda/shihwei/data/viirs_j1_l1b
pyscript="${bundledir}/iodaconv/src/compo/viirs_l1bnc2ioda.py -i VJ102MOD/2021/235/VJ102MOD.A2021235.1[5-9]* VJ102MOD/2021/235/VJ102MOD.A2021235.2[0-1]* -g VJ103MOD/2021/235/VJ103MOD.A2021235.1[5-9]* VJ103MOD/2021/235/VJ103MOD.A2021235.2[0-1]* -n 0.99 -o /work2/noaa/jcsda/shihwei/data/jedi-data/input/obs/viirs_j1_albedo-thinned_p99/obs.PT6H.viirs_j1_albedo-thinned_p99.2021082318.nc4 --secterm"

cd $running_under

echo "$(date) Running: $pyscript"
  python $pyscript
echo "$(date) End: $pyscript"
