#!/usr/bin/env bash

tarball_dir="/glade/derecho/scratch/swei/Wx-AQ/tarballs"
desdir="/glade/derecho/scratch/swei/Dataset/input/bkg/wxaq"

sdate=2024082300
edate=2024083100
hint=24

func_ndate (){
    hrinc=$1
    syear=${2:0:4}
    smon=${2:4:2}
    sday=${2:6:2}
    shr=${2:8:2}

    datein=`date -u --date="$smon/$sday/$syear $shr:00:00"`
    dateout=`date +%Y%m%d%H -u -d "$datein $hrinc hours"`
    echo $dateout
}

cd $desdir

cdate=$sdate
until [ $cdate -gt $edate ]; do
    y4=${cdate:0:4}
    m2=${cdate:4:2}
    d2=${cdate:6:2}
    h2=${cdate:8:2}
    tarball=${tarball_dir}/${y4}/${m2}/wrfgsi.out.${y4}${m2}${d2}.tgz
    echo $tarball
    
    tar -zxvf $tarball --wildcards "wrfgsi.out.${cdate}/subset_*"
  
    cdate=`func_ndate $hint $cdate`
done
