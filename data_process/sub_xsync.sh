#!/bin/bash --login
#SBATCH --job-name=movedata
#SBATCH --account=wrf-chem
#SBATCH --partition=service
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --output=/home/Shih-wei.Wei/wrk/logs/movedata.out.%j

set -x

SRC=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/common/GDAS
DEST=/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/common/GDAS

OUT=/home/Shih-wei.Wei/wrk/logs/movedata.log
echo “$(date) : Starting sync from $SRC to $DEST”>> $OUT

xsync -axv $SRC $DEST >> $OUT 2>&1
#rsync -ax $SRC $DEST>> $OUT 2>&1                  # --delete should not be needed

echo “$(date) : Ending sync from $SRC to $DEST”>> $OUT
