#!/usr/bin/env bash
#PBS -N run_py_script
#PBS -A nmmm0035
#PBS -q develop
#PBS -l select=1:ncpus=1:mpiprocs=1:mem=128Gb
#PBS -l walltime=6:00:00
#PBS -j oe
#PBS -o /glade/work/swei/runlogs/run_py_script.log.olr2tb
#PBS -V

export HDF5_USE_FILE_LOCKING=FALSE
ulimit -s unlimited || true
ulimit -v unlimited || true


pyscript=/glade/work/swei/projects/hydrosat/pyscripts/MPAS_plot.py

pycmd=`which python`

$pycmd $pyscript
