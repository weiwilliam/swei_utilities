#!/bin/bash -ax
#SBATCH --job-name=run_pyscripts
#SBATCH --time=02:00:00
#SBATCH --account=star
##SBATCH --partition=s4
##SBATCH --nodes=1
##SBATCH --cpus-per-task=1
##SBATCH --exclusive
#SBATCH --partition=serial
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=64000
#SBATCH --output=/data/users/swei/runlogs/sub_py_log.%j

source /etc/profile
source /home/swei/.conda-source
module load miniconda/3.8-s4
conda activate swei

export HDF5_USE_FILE_LOCKING='FALSE'
#pyscript=/home/swei/research/pyscripts/HazyDA/exps_verify_tsprofs.py
#pyscript=/home/swei/research/pyscripts/HazyDA/exps_verify_2dmap.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_OMB_boxplot.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_gridded_bias.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_gridded_omb.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_gridded_qcflags.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_newQC_OMBPDF.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_gridded_aercnts.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_newQC_hist.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_1ch_bcterm.py
#pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_NormOMB_cmp.py
pyscript=/home/swei/research/pyscripts/HazyDA/ncrad_NormOMB.py
#pyscript=/home/swei/research/pyscripts/ncrad_newQC_stats.py
#pyscript=/home/swei/research/pyscripts/m2_aer_massden_2dmap.py
#pyscript=/home/swei/research/pyscripts/create_ncens_rmse_spread.py
python $pyscript
