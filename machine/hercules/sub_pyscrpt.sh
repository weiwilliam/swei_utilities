#!/usr/bin/bash
#SBATCH --job-name=swei_runpy
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=0:30:00
#SBATCH --account=da-cpu
#SBATCH --partition=hercules
#SBATCH --qos=debug
#SBATCH --mem=64gb
##SBATCH --exclusive
#SBATCH --output=/work2/noaa/jcsda/shihwei/slurmlogs/runpy.log.%j

#Information of Orion
#https://intranet.hpc.msstate.edu/helpdesk/resource-docs/orion_guide.php

set -x

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING='FALSE'

#bundledir=/work2/noaa/jcsda/shihwei/skylab/jedi-bundle
#running_under=/work2/noaa/jcsda/shihwei/data/viirs_j1_l1b
#cd $running_under
# pyscript="${bundledir}/iodaconv/src/compo/viirs_l1bnc2ioda.py -i VJ102MOD/2021/235/VJ102MOD.A2021235.1[5-9]* VJ102MOD/2021/235/VJ102MOD.A2021235.2[0-1]* -g VJ103MOD/2021/235/VJ103MOD.A2021235.1[5-9]* VJ103MOD/2021/235/VJ103MOD.A2021235.2[0-1]* -n 0.99 -o /work2/noaa/jcsda/shihwei/data/jedi-data/input/obs/viirs_j1_albedo-thinned_p99/obs.PT6H.viirs_j1_albedo-thinned_p99.2021082318.nc4 --secterm"

#pyscript="/home/shihwei/Git/research/pyscripts/MAPP/openaq2ioda.py"

cd /work2/noaa/jcsda/shihwei/skylab/jedi-bundle/iodaconv

pyscript1="/usr/bin/time -v ./src/compo/viirs_aod2ioda.py -i /work/noaa/uswrp-hu/mbenneh/raw_data/viirs_raw/20230603/JRR-AOD_v3r2_j01_s20230603* -o old_file.nc4 --provider noaa --error_method pue --thin 0.99 --date_range 2023060309 2023060315"
pyscript2="/usr/bin/time -v ./src/compo/viirs_aod2ioda_2.py -i /work/noaa/uswrp-hu/mbenneh/raw_data/viirs_raw/20230603/JRR-AOD_v3r2_j01_s20230603* -o old2_file.nc4 --provider noaa --error_method pue --thin 0.99 --date_range 2023060309 2023060315"
pyscript3="/usr/bin/time -v ./src/compo/viirs_aod2ioda_new.py -i /work/noaa/uswrp-hu/mbenneh/raw_data/viirs_raw/20230603/JRR-AOD_v3r2_j01_s20230603* -o new_file.nc4 --provider noaa --error_method pue --thin 0.99 --date_range 2023060309 2023060315" 
pyscript4="/usr/bin/time -v ./src/compo/viirs_aod2ioda_new2.py -i /work/noaa/uswrp-hu/mbenneh/raw_data/viirs_raw/20230603/JRR-AOD_v3r2_j01_s20230603* -o new2_file.nc4 --provider noaa --error_method pue --thin 0.99 --date_range 2023060309 2023060315"

echo "$(date) Running: $pyscript1"
  $pyscript1 > old_runtime_info.txt 2>&1 
echo "$(date) End: $pyscript1"
echo "$(date) Running: $pyscript2"
  $pyscript2 > old2_runtime_info.txt 2>&1
echo "$(date) End: $pyscript2"
echo "$(date) Running: $pyscript3"
  $pyscript3 > new_runtime_info.txt 2>&1
echo "$(date) End: $pyscript3"
echo "$(date) Running: $pyscript4"
  $pyscript4 > new2_runtime_info.txt 2>&1
echo "$(date) End: $pyscript4"
