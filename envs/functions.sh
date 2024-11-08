#!/usr/bin/env bash
# Define my useful functions and alias crossing all platforms
#
# SLURM system: Orion, S4,
alias showmyslurm='sacctmgr show User $USER --associations'
alias slurmlist='squeue -u ${USER} -o "%.10i %.9P %.6q %.35j %.8u %.8T %.10M %.10L %.3D %R"'
alias slurmdel='scancel'

# PBS system: NCAR machine
alias pbslist='qstat -w -u $USER'
alias pbsdel='qdel'
alias rda='cd /glade/campaign/collections/rda/data'

# Other alias
alias ftpds='sftp swei@data-access.ucar.edu:/glade/work/swei'
alias ftpor='sftp shihwei@Orion-dtn.hpc.msstate.edu:/work2/noaa/jcsda/shihwei'
alias psu='ps -ef | grep ${USER}'
alias killstop='kill -9 `jobs -ps`'
alias la='ls -a'
alias lt='ls -lrt'

#
# slurm allocate
#
echo "alloc_a_node is available for following platforms:"
echo "ds, s4, or, dr"
alloc_a_node(){
case $1 in
'ds')
  salloc --partition=compute --qos=debug --account=s2127 --job-name=interactive --nodes=1 --ntasks-per-node=24 --time=1:00:00 ;;
's4')
  salloc --partition=s4 --account=star --job-name=interactive --nodes=1 --ntasks-per-node=24 --time=1:00:00 ;;
'or')
  salloc --partition=orion --qos=debug --account=da-cpu --job-name=interactive --nodes=1 --ntasks-per-node=24 --time=1:00:00 ;;
'dr')
  qinteractive --ntasks 6 --mem 96GB -l walltime=02:00:00 -l job_priority=economy @derecho ;;
  #qsub -I -X -V -l select=1:ncpus=1:mem=32GB -A UALB0044 -q main -l walltime=1:00:00 -l job_priority=economy  ;;
*) 
  echo "Not supported platform";;
esac
export HDF5_USE_FILE_LOCKING=FALSE
export OOPS_TRACE=1
export OOPS_DEBUG=1
}
