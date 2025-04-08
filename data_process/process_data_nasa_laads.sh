#!/usr/bin/env bash

set -x

start_date=2020061812
  end_date=2020061812
window_len=6

outpath='/data/users/swei/Dataset/VIIRS_J1'
year=2020
jday=170
datastream='5201'
datatype='VJ102MOD'

src_url="https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/${datastream}/${datatype}/${year}/${jday}"
des_path=${outpath}/$datatype/$year/$jday

[[ ! -d $des_path ]] && mkdir -p $des_path

query_files='wget -q ${src_url} -O - | grep data-name | cut -d "=" -f3 | cut -d " " -f1 | rev | cut -c 2- | rev | cut -c 2- || echo ""'

cycfiles=`eval $query_files`
echo $cycfiles

for file in $cycfiles
do
    wget -nc --auth-no-challenge --no-check-certificate ${src_url}/${file} -O ${des_path}/${file}
done 
