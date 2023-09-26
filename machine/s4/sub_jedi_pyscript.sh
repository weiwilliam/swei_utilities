#!/bin/bash -ax
#SBATCH --job-name=run_jedi_py
#SBATCH --time=06:00:00
#SBATCH --account=star
##SBATCH --partition=s4
##SBATCH --nodes=1
##SBATCH --cpus-per-task=1
##SBATCH --exclusive
#SBATCH --partition=serial
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=94000
#SBATCH --output=/data/users/swei/runlogs/sub_jedipy_log.%j

source /etc/bashrc
source /home/swei/.bash_profile
load_skylab_v4
ulimit -s unlimited

export HDF5_USE_FILE_LOCKING='FALSE'

pyscript_home=/data/users/swei/MAPP/pyscript
pyscrpts_list='improve2ioda.py'


for pys in $pyscrpts_list
do
  pyscript=$pyscript_home/$pys
  echo "$(date) Running: $pyscript"
  python $pyscript
  echo "$(date) End: $pyscript"
done
