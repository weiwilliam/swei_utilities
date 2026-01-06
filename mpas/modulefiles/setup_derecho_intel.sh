#!/usr/bin/env bash
module --force purge
module load ncarenv/24.12
module load craype
module load intel
module load ncarcompilers
module load cray-mpich
module load parallel-netcdf # /1.12.3
module load netcdf  # /4.9.2
module load nco
module load conda

#export PYTHONPATH=/glade/campaign/mmm/wmr/mpas_tutorial/python_scripts
#module load ncview
#MPAS_Gits=/glade/work/swei/Git/MPAS
#export PATH=$HOME/Git/utils/mpas/utils:${MPAS_Gits}/MPAS-Limited-Area:${MPAS_Gits}/MPAS-Tools/mesh_tools/grid_rotate:${MPAS_Gits}/convert_mpas:/glade/campaign/mmm/wmr/mpas_tutorial/metis/bin:${PATH}
#module reload gcc/13.2.0

#export NCARG_COLORMAPS=/glade/campaign/mmm/wmr/mpas_tutorial/ncl_colormaps/:$NCARG_ROOT/lib/ncarg/colormaps/
