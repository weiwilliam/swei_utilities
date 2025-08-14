#!/usr/bin/env bash
#PBS -N pandora_processing
#PBS -A NMMM0072
#PBS -q develop
#PBS -l job_priority=economy
#PBS -l select=1:ncpus=4:mem=64Gb
#PBS -l walltime=06:00:00
#PBS -j oe
#PBS -V

if [ -n "$PBS_JOBID" ]; then
    echo "Running under PBS with Job ID: $PBS_JOBID"
    echo "Bring venv upfront"
    export PATH=$JEDI_ROOT/venv/bin:$PATH
fi
#set -x

winbeg=202408212330
winend=202409010030
conv2ioda=1
ioda_outpath=/glade/derecho/scratch/swei/Dataset/input/obs/pandora
jedibuild=/glade/work/swei/skylab/build_oneapi/bin
iodaconv=pandora_2ioda.py
rawdir=/glade/work/swei/data/RawOBS/PANDORA
sitecsv=/glade/work/swei/skylab/jedi-bundle/iodaconv/test/testinput/pandora_site_classification.csv

if [ $conv2ioda -eq 1 ]; then
    $jedibuild/$iodaconv -i $rawdir/* \
                         --site_classification ${sitecsv} \
                         --date_range ${winbeg} ${winend} \
                         -o $ioda_outpath/obs.pandora.2024082200_2024090100.nc4
fi
    
