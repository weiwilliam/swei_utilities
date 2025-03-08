#!/usr/bin/env bash
#SBATCH --job-name=swei_ioda_merging
#SBATCH --account=da-cpu
#SBATCH --qos=batch
#SBATCH --nodes=1
#SBATCH --time=2:00:00
##SBATCH --account=star
#SBATCH --output=/work2/noaa/jcsda/shihwei/slurmlogs/ioda_merging.%j.log
##SBATCH --output=/data/users/swei/runlogs/ioda_merging.%j.log

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

ulimit -s unlimited || true
ulimit -v unlimited || true

filepath='/work2/noaa/jcsda/shihwei/jedi_exps/save_geoval/output/geovals'
filetmp='geovals.viirs_j1_albedo-small.2021082315_0*'
#filepath='/work2/noaa/jcsda/shihwei/jedi_exps/ufo_crtm/output/obsdiag'
#filetmp='jacs.caboverde.viirs_j1_albedo_l1b-70thinned.2021082315_0*'

cd $filepath

file_extension='.nc4'
trimstr="_0000${file_extension}"

filearr=(`ls $filetmp | sort`)
echo ${filearr[@]}

first_file=${filearr[0]}
concat_to=${first_file%${trimstr}}${file_extension}

ncks -O --mk_rec_dmn nlocs $first_file $first_file
ncrcat ${filearr[@]} $concat_to
