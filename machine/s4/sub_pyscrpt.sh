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
#SBATCH --mem-per-cpu=94000
#SBATCH --output=/data/users/swei/runlogs/sub_py_log.%j

source /etc/profile
source /home/swei/.conda-source
module load miniconda/3.8-s4
conda activate swei

export HDF5_USE_FILE_LOCKING='FALSE'

#pyscript_home=/home/swei/research/pyscripts
#pyscrpts_list="plot_ncens_rmse_spread.py" #create_ncens_rmse_spread.py"
pyscript_home=/home/swei/Git/research/pyscripts/HazyDA
pyscrpts_list='test.py'
#pyscrpts_list='nccnv_sfc_biasrms_over_aod.py'
#pyscrpts_list="nccnv_biasrms.py" 
#pyscrpts_list="nccnv_gridded_omb.py"
#pyscrpts_list="exps_against_era5.py" 
#pyscrpts_list="ncrad_2exp_usage.py"
#pyscrpts_list="2exps_cmp_preslv_2dmap.py"
#pyscrpts_list="2exps_cmp_surface_2dmap.py 2exps_cmp_preslv_2dmap.py"
#pyscrpts_list="ncrad_gridded_bias.py"
#pyscrpts_list="ncrad_gridded_varinv.py" #ncrad_gridded_qcflags.py ncrad_gridded_omb.py ncrad_gridded_btd.py"
#pyscrpts_list="ncrad_gridded_obserr.py"
#pyscrpts_list="ncrad_OMB_cmp.py"
#pyscrpts_list='ncrad_aereff_hist2d.py'
#pyscrpts_list='ncrad_newQC_hist_pd.py'
#pyscrpts_list='ncrad_newQC_OMBPDF.py'
#pyscrpts_list='ncrad_newQC_stats.py'
#pyscrpts_list='ncrad_aereff_lines.py'
#pyscrpts_list='ncrad_spec_innov.py'
#pyscrpts_list='ncrad_spec_bias.py'
#pyscrpts_list='ncrad_spec_btd.py'
#pyscrpts_list='ncrad_OMB_boxplot.py'
#pyscrpts_list='ncrad_OMB_PDF_2exps.py'


for pys in $pyscrpts_list
do
  pyscript=$pyscript_home/$pys
  echo "$(date) Running: $pyscript"
  python $pyscript
  echo "$(date) End: $pyscript"
done
