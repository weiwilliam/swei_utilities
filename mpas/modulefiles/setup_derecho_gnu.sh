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
export PATH=/glade/campaign/mmm/wmr/mpas_tutorial/metis/bin:${PATH}
module reload gcc/13.2.0
