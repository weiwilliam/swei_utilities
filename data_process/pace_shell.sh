#!/usr/bin/env bash
set -x

start_cycle=2024110106
  end_cycle=2024110106
cyc_int=6
window=6
ioda_outpath=/glade/derecho/scratch/swei/Dataset/input/obs/oci_pace_aod
jedibuild=/glade/work/swei/skylab/build/bin
iodaconv=pace_aod2ioda.py
wrkdir=/glade/derecho/scratch/swei/wrktmp

cd $wrkdir; rm -rf $wrkdir/*
datecmd=`which date`
current_cycle=$start_cycle
until [ $current_cycle -gt $end_cycle ]; do
    cyr=${current_cycle:0:4}
    cmn=${current_cycle:4:2}
    cdy=${current_cycle:6:2}
    chr=${current_cycle:8:2}

    half_win=$((window*60/2))
    datein=`date -u --date="$cmn/$cdy/$cyr $chr:00:00"`
    sdate=`date +"%Y-%m-%d %H:%M:00" -u -d "$datein -$half_win minutes"`
    edate=`date +"%Y-%m-%d %H:%M:00" -u -d "$datein +$half_win minutes"`
    echo $sdate $edate

    api_args="results_as_file=1&sensor_id=42&dtid=1826&sdate=${sdate}&edate=${edate}&subType=1"
    
    file_list=`wget -q --post-data="$api_args" -O - https://oceandata.sci.gsfc.nasa.gov/api/file_search`
    getfile_url="https://oceandata.sci.gsfc.nasa.gov/getfile"
    
    for pace_file in $file_list
    do  
        wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies \
             --auth-no-challenge=on --content-disposition \
             $getfile_url/$pace_file
    done

    $jedibuild/$iodaconv -i $file_list -o $ioda_outpath/oci_pace_aod.${current_cycle}.nc4
    
    current_cycle=`date +%Y%m%d%H -u -d "$datein $cyc_int hours"`
done
