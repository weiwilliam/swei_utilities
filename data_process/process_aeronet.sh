#!/usr/bin/env bash
#
# process_aeronet.sh
#
#   Download AERONET AOD ASCII files from the NASA web service and/or convert
#   them into IODA files with <build>/bin/aeronet_aod2ioda.py.
#
#   Files follow the pandac observation convention:
#       raw : ${raw_path}/${product}/${cdate}/${product}_${cdate}.dat
#       ioda: ${out_path}/${product}/${cdate}/${product}_obs_${cdate}.h5
#
#   Example:
#       ./process_aeronet.sh -b /glade/work/swei/skylab/build_oneapi \
#                            -s 2024072100 -e 2024073118 -w 6 \
#                            -r /glade/derecho/scratch/swei/Dataset/rawobs \
#                            -o /glade/campaign/ncar/nmmm0081/input/obs
#
set -u

usage() {
cat << USAGE
Usage: $(basename $0) [options]

Required:
  -s, --start   YYYYMMDDHH  first analysis cycle
  -r, --rawdir  DIR         root directory for the raw AERONET ASCII files
Required unless --mode download:
  -b, --build   DIR         JEDI bundle build directory (uses DIR/bin/aeronet_aod2ioda.py)
  -o, --outdir  DIR         root directory for the converted IODA files

Optional:
  -e, --end     YYYYMMDDHH  last analysis cycle              (default: same as --start)
  -w, --window  HOURS       assimilation window length       (default: 6)
  -i, --interval HOURS      cycle increment                  (default: same as --window)
  -m, --mode    MODE        download | convert | both        (default: both)
  -l, --level   LEVEL       AOD quality level: 10, 15 or 20  (default: 15)
  -a, --avg     AVG         10 = all points, 20 = daily avg  (default: 10)
  -p, --product NAME        product/observation type name    (default: aeronet_aod)
  -f, --force               re-download even if the raw file already exists
  -h, --help                show this message

The window is centered on each cycle, i.e. [cdate-window/2, cdate+window/2].
USAGE
}

# ---------------------------------------------------------------- defaults ---
build=""
start_cdate=""
end_cdate=""
window=6
interval=""
raw_path=""
out_path=""
mode="both"
level=15
avg=10
product="aeronet_aod"
force=0

# ------------------------------------------------------------------- parse ---
while [[ $# -gt 0 ]]; do
    case $1 in
    -b|--build)    build=$2;       shift 2 ;;
    -s|--start)    start_cdate=$2; shift 2 ;;
    -e|--end)      end_cdate=$2;   shift 2 ;;
    -w|--window)   window=$2;      shift 2 ;;
    -i|--interval) interval=$2;    shift 2 ;;
    -r|--rawdir)   raw_path=$2;    shift 2 ;;
    -o|--outdir)   out_path=$2;    shift 2 ;;
    -m|--mode)     mode=$2;        shift 2 ;;
    -l|--level)    level=$2;       shift 2 ;;
    -a|--avg)      avg=$2;         shift 2 ;;
    -p|--product)  product=$2;     shift 2 ;;
    -f|--force)    force=1;        shift   ;;
    -h|--help)     usage; exit 0           ;;
    *) echo "ERROR: unknown option: $1"; usage; exit 1 ;;
    esac
done

case $mode in
'download'|'convert'|'both') ;;
*) echo "ERROR: --mode must be download, convert or both (got: $mode)"; exit 1 ;;
esac

case $level in
10|15|20) ;;
*) echo "ERROR: --level must be 10, 15 or 20 (got: $level)"; exit 1 ;;
esac

case $avg in
10|20) ;;
*) echo "ERROR: --avg must be 10 (all points) or 20 (daily average) (got: $avg)"; exit 1 ;;
esac

[[ -z $start_cdate ]] && { echo "ERROR: --start is required"; usage; exit 1; }
[[ -z $end_cdate   ]] && end_cdate=$start_cdate
[[ -z $interval    ]] && interval=$window
[[ -z $raw_path    ]] && { echo "ERROR: --rawdir is required"; usage; exit 1; }

if [[ $mode != 'download' ]]; then
    [[ -z $build    ]] && { echo "ERROR: --build is required for mode $mode";  usage; exit 1; }
    [[ -z $out_path ]] && { echo "ERROR: --outdir is required for mode $mode"; usage; exit 1; }
fi

for cdate in $start_cdate $end_cdate; do
    if [[ ! $cdate =~ ^[0-9]{10}$ ]]; then
        echo "ERROR: cycle must be YYYYMMDDHH (got: $cdate)"; exit 1
    fi
    if ! date -ud "${cdate:0:4}-${cdate:4:2}-${cdate:6:2} ${cdate:8:2}:00:00" >/dev/null 2>&1; then
        echo "ERROR: invalid cycle date: $cdate"; exit 1
    fi
done
[[ $start_cdate -gt $end_cdate ]] && { echo "ERROR: --start is later than --end"; exit 1; }

if [[ $((window % 2)) -ne 0 ]]; then
    echo "ERROR: --window must be an even number of hours (the AERONET service"
    echo "       only accepts whole hours and the window is centered on the cycle)"
    exit 1
fi

# --------------------------------------------------------------- environment ---
iodaconv=""
if [[ $mode != 'download' ]]; then
    iodaconv=${build}/bin/aeronet_aod2ioda.py
    if [[ ! -s $iodaconv ]]; then
        echo "ERROR: converter not found: $iodaconv"; exit 1
    fi
    if [[ -n ${PBS_JOBID:-} && -n ${JEDI_ROOT:-} && -d ${JEDI_ROOT}/venv/bin ]]; then
        echo "Running under PBS with Job ID: $PBS_JOBID -- bring venv upfront"
        export PATH=${JEDI_ROOT}/venv/bin:$PATH
    fi
    PYTHON_VERSION=$(python3 -c 'import sys; version=sys.version_info[:2]; print("{0}.{1}".format(*version))')
    export PYTHONPATH="${build}/lib/python${PYTHON_VERSION}:${PYTHONPATH:-}"
fi

aeronet_url="https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_v3"
half_win=$((window * 60 / 2))

echo "AERONET AOD processing"
echo "  product  : $product (AOD${level}, AVG=${avg})"
echo "  cycles   : $start_cdate to $end_cdate every $interval h, window $window h"
echo "  mode     : $mode"
echo "  raw path : $raw_path/$product"
[[ $mode != 'download' ]] && echo "  ioda path: $out_path/$product"
[[ $mode != 'download' ]] && echo "  converter: $iodaconv"
echo ""

# ---------------------------------------------------------------- functions ---
# A valid AERONET ASCII file carries a 6 line header followed by the data
# records; anything shorter (or an HTML error page) means no data.
check_rawfile() {
    local rawfile=$1
    [[ -s $rawfile ]] || return 1
    grep -qi "<html" $rawfile && return 1
    [[ $(wc -l < $rawfile) -gt 6 ]] || return 1
    return 0
}

download_cycle() {
    local cdate=$1 rawfile=$2
    local cdatestr=$(date -ud "${cdate:0:4}-${cdate:4:2}-${cdate:6:2} ${cdate:8:2}:00:00" +"%Y-%m-%d %H:%M:%S")
    local window_begin=$(date -ud "$cdatestr $half_win minutes ago" +%Y-%m-%dT%H)
    local window_end=$(date -ud "$cdatestr $half_win minutes"      +%Y-%m-%dT%H)

    echo "    window: $window_begin to $window_end (UTC)"
    curl -s --fail --retry 3 --retry-delay 5 --connect-timeout 30 -o $rawfile \
         "${aeronet_url}?AOD${level}=1&tz=UTC&AVG=${avg}&if_no_html=1&year=${window_begin:0:4}&month=${window_begin:5:2}&day=${window_begin:8:2}&hour=${window_begin:11:2}&year2=${window_end:0:4}&month2=${window_end:5:2}&day2=${window_end:8:2}&hour2=${window_end:11:2}"
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "    FAILED: curl exited with status $rc"
        rm -f $rawfile
        return 1
    fi
    if ! check_rawfile $rawfile; then
        echo "    FAILED: no AERONET data returned for this window"
        rm -f $rawfile
        return 1
    fi
    echo "    downloaded: $rawfile ($(($(wc -l < $rawfile) - 6)) records)"
    return 0
}

convert_cycle() {
    local cdate=$1 rawfile=$2
    if ! check_rawfile $rawfile; then
        echo "    SKIPPED: no usable raw file at $rawfile"
        return 1
    fi
    local out_cdate_dir=${out_path}/${product}/${cdate}
    [[ ! -d $out_cdate_dir ]] && mkdir -p $out_cdate_dir
    local outfile=${out_cdate_dir}/${product}_obs_${cdate}.h5
    $iodaconv -i $rawfile -o $outfile
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        echo "    FAILED: $(basename $iodaconv) exited with status $rc"
        return 1
    fi
    echo "    converted: $outfile"
    return 0
}

# --------------------------------------------------------------------- loop ---
n_ok=0
n_fail=0
cdate=$start_cdate
until [[ $cdate -gt $end_cdate ]]; do
    echo "  At cycle: $cdate"

    raw_cdate_dir=${raw_path}/${product}/${cdate}
    rawfile=${raw_cdate_dir}/${product}_${cdate}.dat
    status=0

    if [[ $mode == 'download' || $mode == 'both' ]]; then
        [[ ! -d $raw_cdate_dir ]] && mkdir -p $raw_cdate_dir
        if [[ $force -eq 0 ]] && check_rawfile $rawfile; then
            echo "    raw file already exists, skip download (use --force to override)"
        else
            download_cycle $cdate $rawfile || status=1
        fi
    fi

    if [[ $status -eq 0 && ( $mode == 'convert' || $mode == 'both' ) ]]; then
        convert_cycle $cdate $rawfile || status=1
    fi

    [[ $status -eq 0 ]] && n_ok=$((n_ok + 1)) || n_fail=$((n_fail + 1))

    cdate=$(date -ud "${cdate:0:4}-${cdate:4:2}-${cdate:6:2} ${cdate:8:2}:00:00 $interval hours" +%Y%m%d%H)
done

echo ""
echo "Done: $n_ok cycle(s) succeeded, $n_fail cycle(s) failed/skipped"
[[ $n_fail -gt 0 ]] && exit 1
exit 0
