#!/bin/ksh
if [[ -d /scratch1 ]] ; then
    . /apps/lmod/lmod/init/sh
    target=hera
    export JEDI_OPT=/scratch1/NCEPDEV/jcsda/jedipara/opt/modules
    module use $JEDI_OPT/modulefiles/core
    module purge
    module load jedi/intel-impi/2020.2
    export SLURM_ACCOUNT=gsd-fv3-dev
    export SALLOC_ACCOUNT=$SLURM_ACCOUNT
    export SBATCH_ACCOUNT=$SLURM_ACCOUNT
elif [[ -d /carddata ]] ; then
    #. /opt/apps/lmod/3.1.9/init/sh
    target=s4
    export JEDI_OPT=/data/users/mmiesch/modules
    module use $JEDI_OPT/modulefiles/core
    module load jedi/intel-impi
elif [[ -d /work ]]; then
    . $MODULESHOME/init/sh
    target=orion
    export JEDI_OPT=/work/noaa/da/grubin/opt/modules
    module use $JEDI_OPT/modulefiles/core
    module load jedi/intel-impi
elif [[ -d /glade ]] ; then
    . $MODULESHOME/init/sh
    target=cheyenne
    module purge
    export OPT=/glade/work/miesch/modules
    module use $OPT/modulefiles/core
fi
echo "It's on $target"
module list
