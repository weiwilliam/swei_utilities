#!/usr/bin/env bash
orig_ioda_path='/data/users/swei/Dataset/VIIRS_NPP/ioda_viirs_aod'
crop_ioda_path='/data/users/swei/Dataset/VIIRS_NPP/ioda_viirs_aod-wxaq'

croppy='/home/swei/Git/utils/jedi/ioda_utils/crop_iodafile.py'
polyfile='/data/users/swei/Git/JEDI/JEDI-METplus/etc/polygons/wxaq_polygon.csv'
var='aerosolOpticalDepth'
prefix='wxaq'

for file in `ls $orig_ioda_path`
do
    echo "Processing ${file}"
    in_file=${orig_ioda_path}/${file}
    outfile=${crop_ioda_path}/${prefix}-${file}
    $croppy -i ${in_file} -o ${outfile} -v ${var} -p ${polyfile}
done
