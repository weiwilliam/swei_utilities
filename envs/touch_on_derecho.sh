#!/usr/bin/env bash

scratch_dir="/glade/derecho/scratch/swei"

touch_list="Dataset Dustin UFS Wx-AQ"

for dir in $touch_list
do
    echo "Processing $dir"
    find $scratch_dir/$dir -exec touch {} +
done
