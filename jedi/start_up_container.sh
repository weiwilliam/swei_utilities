#!/bin/bash
set -o emacs
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
alias sc='cd /worktmp'
alias ss='cd /scratch/short/users/${USER}'
alias jedisg='singularity shell --bind ${SCDIR}:/worktmp -e /data/users/swei/Builds/container/jedi-tutorial_latest.sif'


