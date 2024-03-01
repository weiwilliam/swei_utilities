#!/usr/bin/env bash

file_extension='.nc4'
trimstr="_0000${file_extension}"

filelist=$@
filearr=(`ls $filelist | sort`)
echo ${filearr[@]}

first_file=${filearr[0]}
concat_to=${first_file%${trimstr}}${file_extension}

ncks -O --mk_rec_dmn nlocs $first_file $first_file
ncrcat ${filearr[@]} $concat_to
