#!/usr/bin/env bash
#SBATCH --job-name=swei_ioda_merging
#SBATCH --account=star
#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --output=/data/users/swei/runlogs/ioda_merging.%j.log
##SBATCH --mail-user=<email-address>

filepath='/data/users/swei/JEDI/ufo_crtm/output_0aer/obsdiag'
filetmp='jacs.viirs_j1_albedo_l1b-70thinned.2021080504_0*'

cd $filepath

file_extension='.nc4'
trimstr="_0000${file_extension}"

filearr=(`ls $filetmp | sort`)
echo ${filearr[@]}

first_file=${filearr[0]}
concat_to=${first_file%${trimstr}}${file_extension}

ncks -O --mk_rec_dmn nlocs $first_file $first_file
ncrcat ${filearr[@]} $concat_to
