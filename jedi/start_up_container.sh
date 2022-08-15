#!/bin/bash
# JEDI environment
export JEDI_OPT=/data/prod/jedi/opt/modules
#export JEDI_OPT=/data/users/mmiesch/modules
module use $JEDI_OPT/modulefiles/core

export HDF5_USE_FILE_LOCKING=FALSE

export fpd=/data/users/swei/FTPdir
export satd=/ships19/aqda/bpierce/Satellite

#alias
alias la='ls -a'
alias lt='ls -lrt'
alias psu='ps -ef | grep ${USER}'
alias data='cd /data/users/swei'
alias js='squeue -u ${USER} -o "%.10i %.9P %.6q %.35j %.8u %.8T %.10M %.10L %.3D %R"'
alias jd='scancel'
alias sc='cd /scratch/users/${USER}'
alias ss='cd /scratch/short/users/${USER}'
alias py3="conda activate swei ; export HDF5_USE_FILE_LOCKING='FALSE'"
alias py2="conda activate py27 ; export HDF5_USE_FILE_LOCKING='FALSE'"
alias dpy='conda deactivate'
alias pyncl='conda activate ncl_stable'
alias jedisg='singularity shell --bind /scratch/users/swei/container:/worktmp -e /data/users/swei/Builds/container/jedi-tutorial_latest.sif'


