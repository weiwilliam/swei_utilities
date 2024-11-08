#!/usr/bin/bash

echo "JEDI_ROOT: $JEDI_ROOT"
echo "JEDI_SRC: $JEDI_SRC"

load_skylab () {
    machine=$1
    compiler=$2
    # Check whether $JEDI_ROOT/jedi-tools exist.
    if [ ! -s $JEDI_ROOT/jedi-tools ]; then
        echo "Please clone jedi-tools under $JEDI_ROOT first"
    else
        if [ -s $JEDI_ROOT/jedi-tools/buildscripts/setup/${machine}_setup_${compiler}.sh ]; then 
            source $JEDI_ROOT/jedi-tools/buildscripts/setup/${machine}_setup_${compiler}.sh
	    module load jedi-fv3-env
            module load ewok-env
            module load soca-env
            module load metplus
        else
            echo "${machine}_setup_${compiler}.sh is not available"
        fi
    fi
}

pipreinstall (){
    source $JEDI_ROOT/venv/bin/activate
    repos="solo r2d2 ewok simobs skylab"
    for dir in $repos
    do
        if [ ! -d $JEDI_SRC/$dir ]; then
            cd $JEDI_SRC
            git clone https://github.com/jcsda-internal/$dir
        fi
        if [ $dir != 'skylab' ]; then
            cd $JEDI_SRC/$dir
            python3 -m pip install -e .
        fi
    done
}

activate_skylab (){
    if [ ! -s $JEDI_ROOT/jedi-tools ]; then
        echo "Please clone jedi-tools under $JEDI_ROOT first"
    else
	source $JEDI_ROOT/jedi-tools/buildscripts/setup.sh
	module load metplus
    fi
}

jumptolg (){
    login_no=$1
    ssh -Y Orion-login-${login_no}
}

show_exps (){
    ecflow_client --suites
}
remove_exp (){
    expid=$1
    if [ ! -z $expid ]; then
        ecflow_client --delete=force yes /$expid
        [[ -d $JEDI_ROOT/workdir/$expid ]] && rm -rf $JEDI_ROOT/workdir/$expid
        [[ -d $JEDI_ROOT/ecflow/$expid ]] && rm -rf $JEDI_ROOT/workdir/$expid
    fi
}

