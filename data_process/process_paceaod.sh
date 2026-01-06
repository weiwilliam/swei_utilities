#!/usr/bin/env bash
#PBS -N process_paceaod
#PBS -A NMMM0072
#PBS -q develop
#PBS -l select=1:ncpus=1:mem=64Gb
#PBS -l walltime=06:00:00
#PBS -j oe
#PBS -V

if [ -n "$PBS_JOBID" ]; then
    echo "Running under PBS with Job ID: $PBS_JOBID"
    echo "Bring venv upfront"
    export PATH=$JEDI_ROOT/venv/bin:$PATH
fi
#set -x

sensor='oci'
retrieval='uaa'
start_cycle=2024101500
  end_cycle=2024101918
cyc_int=6
window=6
conv2ioda=1
keep_raw=1
ioda_outpath=/glade/campaign/ncar/nmmm0072/Data/obs/ociuaa_pace_aod
jedibuild=/glade/work/swei/skylab/build_oneapi/bin
iodaconv=pace_aod2ioda.py
wrkdir=/glade/derecho/scratch/swei/data_process_tmp/pace_ociuaa_aod
rawdir=/glade/derecho/scratch/swei/Dataset/rawobs/ociuaa_pace_aod
getfile_url="https://oceandata.sci.gsfc.nasa.gov/getfile"

case $sensor in
'oci')
    # OCI UAA, senid=42
    # OCI UAA Refined v3.1, dtid=1823
    # OCI UAA NRT v3.1, dtid=1825
    case $retrieval in
    'uaa')
        senid=42; dtid_list="1823" ;;
    *)
        echo "Unknown retrieval for OCI, available list: uaa"
        exit 1 ;;
    esac
;;
'spexone')
    case $retrieval in
    'remotap')
        # SPEXone RemoTAP (NRT Ocean: 1350, Land: 1351)
        #                 (Refined Ocean: 1420, Land: 1421)
        senid=41; dtid_list="1420 1421" ;;
    'fmapol')
        # SPEXone FastMAPOL refined v3.0 (Ocean only)
        senid=41; dtid_list="1971" ;;
    *)
        echo "Unknown retrieval for SPEXone, available list: remotap, fmapol"
        exit 1 ;;
    esac
;;
'harp2')
    case $retrieval in
    'fmapol')
        # HARP2 FastMAPOL refined v3.0 (Ocean only)
        senid=48; dtid_list="1547" ;;
    *)
        echo "Unknown retrieval for HARP2, available list: fmapol"
        exit 1 ;;
    esac
;;
esac

if [ ! -d $ioda_outpath ]; then
    mkdir -p $ioda_outpath
fi
if [ ! -d $wrkdir ]; then
    mkdir -p $wrkdir
fi

cd $wrkdir
datecmd=`which date`
current_cycle=$start_cycle
until [ $current_cycle -gt $end_cycle ]; do
    rm -rf $wrkdir/*
    cyr=${current_cycle:0:4}
    cmn=${current_cycle:4:2}
    cdy=${current_cycle:6:2}
    chr=${current_cycle:8:2}

    half_win=$((window*60/2))
    datein=`date -u --date="$cmn/$cdy/$cyr $chr:00:00"`
    sdate=`date +"%Y-%m-%d %H:%M:00" -u -d "$datein -$half_win minutes"`
    edate=`date +"%Y-%m-%d %H:%M:00" -u -d "$datein +$half_win minutes"`
    winbeg=`date +"%Y%m%d%H" -u -d "$sdate"`
    winend=`date +"%Y%m%d%H" -u -d "$edate"`
    echo $sdate $edate
    file_list=""
    for dtid in $dtid_list
    do 
        api_args="results_as_file=1&sensor_id=${senid}&dtid=${dtid}&sdate=${sdate}&edate=${edate}&subType=1"
        tmplist=`wget -q --post-data="$api_args" -O - https://oceandata.sci.gsfc.nasa.gov/api/file_search`
        file_list="$tmplist $file_list"
    done
    for pace_file in $file_list
    do  
        wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies \
             --auth-no-challenge=on --content-disposition \
             $getfile_url/$pace_file
    done

    if [ $conv2ioda -eq 1 ]; then
        $jedibuild/$iodaconv -i $file_list \
                             --retrieval_method ${retrieval} \
                             --date_range ${winbeg} ${winend} \
                             -o $ioda_outpath/${sensor}_pace_aod.${current_cycle}.nc4
    fi
    
    if [ $keep_raw -eq 1 ]; then
        mkdir -p $rawdir/$current_cycle
        chmod 775 $rawdir/$current_cycle
        mv $wrkdir/*.nc $rawdir/$current_cycle
    fi
 
    current_cycle=`date +%Y%m%d%H -u -d "$datein $cyc_int hours"`
done
