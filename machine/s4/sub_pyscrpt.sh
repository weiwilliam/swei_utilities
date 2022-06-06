#!/bin/bash -ax
#SBATCH --job-name=run_pyscripts
#SBATCH --time=09:00:00
#SBATCH --account=star
##SBATCH --partition=s4
##SBATCH --nodes=1
##SBATCH --cpus-per-task=1
##SBATCH --exclusive
#SBATCH --partition=serial
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=72000
#SBATCH --output=/data/users/swei/runlogs/sub_py_log.%j

source /etc/profile
source /home/swei/.conda-source
module load miniconda/3.8-s4
conda activate swei

export HDF5_USE_FILE_LOCKING='FALSE'

pyscrpts_list="plot_ncens_rmse_spread.py" #create_ncens_rmse_spread.py"
#pyscrpts_list="nccnv_gridded_omb.py"
#pyscrpts_list="ncrad_gridded_qcflags.py ncrad_gridded_omb.py ncrad_gridded_btd.py ncrad_gridded_bias.py"
pyscript_home=/home/swei/research/pyscripts
#pyscript_home=/home/swei/research/pyscripts/HazyDA

for pys in $pyscrpts_list
do
  pyscript=$pyscript_home/$pys
  echo "$(date) Running: $pyscript"
  python $pyscript
  echo "$(date) End: $pyscript"
done

#exps_verify_tsprofs.py
#exps_verify_2dmap.py
#2exps_cmp_preslv_2dmap.py
#2exps_cmp_surface_2dmap.py
#ncrad_OMB_boxplot.py
#ncrad_gridded_bias.py
#ncrad_gridded_omb.py
#ncrad_gridded_btd.py
#ncrad_gridded_qcflags.py
#ncrad_gridded_aercnts.py
#ncrad_newQC_OMBPDF.py
#ncrad_newQC_hist_pd.py
#ncrad_1ch_bcterm.py
#ncrad_1ch_innov.py
#ncrad_NormOMB_cmp.py
#ncrad_NormOMB.py
#ncrad_OMB_hist.py
#ncrad_OMB_cmp.py
#ncrad_newQC_stats.py
#pyscript=/home/swei/research/pyscripts/m2_aer_massden_2dmap.py
#pyscript=/home/swei/research/pyscripts/create_ncens_rmse_spread.py
