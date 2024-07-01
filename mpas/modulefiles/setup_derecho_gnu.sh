#!/usr/bin/env bash
module --force purge
module load ncarenv/23.09
module load craype/2.7.23
module load gcc/13.2.0
module load ncarcompilers/1.0.0
module load cray-mpich/8.1.27
module load parallel-netcdf/1.12.3
module load netcdf/4.9.2
module load conda
conda activate npl
export PYTHONPATH=/glade/campaign/mmm/wmr/mpas_tutorial/python_scripts
module load ncview
MPAS_Gits=/glade/work/swei/Git/MPAS
export PATH=$HOME/Git/utils/mpas/utils:${MPAS_Gits}/MPAS-Limited-Area:${MPAS_Gits}/MPAS-Tools/mesh_tools/grid_rotate:${MPAS_Gits}/convert_mpas:/glade/campaign/mmm/wmr/mpas_tutorial/metis/bin:${PATH}
module reload gcc/13.2.0

export NCARG_COLORMAPS=/glade/campaign/mmm/wmr/mpas_tutorial/ncl_colormaps/:$NCARG_ROOT/lib/ncarg/colormaps/
