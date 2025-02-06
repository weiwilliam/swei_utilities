#!/usr/bin/env bash
jedi_datapath='/work2/noaa/jcsda/shihwei/data/jedi-data/input/obs'

prefix='wxaq'
obsname="tempo_no2_tropo"
orig_ioda_path="${jedi_datapath}/${obsname}-full"
crop_ioda_path="${jedi_datapath}/${obsname}-${prefix}"

croppy="${HOME}/Git/utils/jedi/ioda_utils/crop_iodafile.py"
polyfile='/work2/noaa/jcsda/shihwei/git/JEDI-METplus/etc/polygons/wxaq_polygon.csv'

for file in `ls ${orig_ioda_path}/obs.${obsname}.*`
do
    timetag=`echo $(basename $file) | sed -e 's/\./ /g' | awk '{print $(NF-1)}'`
    suffix=`echo $(basename $file) | sed -e 's/\./ /g' | awk '{print $(NF)}'`
    in_file=${file}
    outfile=${crop_ioda_path}/obs.${obsname}-${prefix}.${timetag}.${suffix}
    echo "Processing `basename ${file}` to `basename ${outfile}`"
    $croppy -i ${in_file} -o ${outfile} -p ${polyfile}
done
