#!/usr/bin/env bash
# Define my useful functions and alias crossing all platforms
#
# SLURM system: Orion, S4,
alias showmyslurm='sacctmgr show User $USER --associations'
alias slurmlist='squeue -u ${USER} -o "%.10i %.9P %.6q %.35j %.8u %.8T %.10M %.10L %.3D %R"'
alias slurmdel='scancel'

# PBS system: NCAR machine
alias pbslist='qstat -u $USER'
alias pbsdel='qdel'
alias rda='cd /glade/campaign/collections/rda/data'

# Other alias
alias ftpds='sftp swei@data-access.ucar.edu'
alias psu='ps -ef | grep ${USER}'
alias killstop='kill -9 `jobs -ps`'
alias la='ls -a'
alias lt='ls -lrt'

