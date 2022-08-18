#!/bin/ksh -l
#SBATCH -J orion2niagara
##SBATCH -q debug
#SBATCH -p service
#SBATCH -A gsd-fv3-dev
#SBATCH -n 1
#SBATCH -D /home/swei/utils/machine/orion
##SBATCH --ntasks-per-node=1
#SBATCH -t 0:29:00
#SBATCH -e /work/noaa/gsd-fv3-dev/swei/logs/o2nlogs/qslogs/%x.e%j
#SBATCH -o /work/noaa/gsd-fv3-dev/swei/logs/o2nlogs/qslogs/%x.o%j

#sbatch --export=ALL sbatch_o2n_mapp_2018.sh

job_o2n=`squeue --noh -u swei | grep backup`
rc=$?

if [[ $rc -eq 0 ]]
then
    echo "o2n tar job running - will resubmit later - exiting now"
    exit 1
else
    echo "Proceed with Orion to Niagara transfer"
fi

#expname=ccpp-chem.noda-ctl
#backupdir=/work/noaa/gsd-fv3-dev/swei/$expname/dr-data_noda-ctl-backup

expname=ccpp-chem
backupdir=/work/noaa/gsd-fv3-dev/swei/$expname/dr-data-backup

orionEP=84bad22e-cb80-11ea-9a44-0255d23c44ef
orionDir=${backupdir}
orionLogDir=/work/noaa/gsd-fv3-dev/swei/logs/o2nlogs

niagEP=21467dd0-afd6-11ea-8f12-0a21f750d19b
niagDir=/collab1/data/Shih-wei.Wei/mapp_2018/$expname

. /etc/profile

module load python/3.7.5

cd $backupdir

ls -1 gdas*/*/*tar > /dev/null 2>&1 
rcc=$?

if [[ $rcc -eq 0 ]]
then
    cfiles=`ls -1 gdas*/*/*tar`
    for file in ${cfiles[*]}
    do
	bfile=`basename ${file}`
	ident=`echo $file | tail -c15 | cut -c 1-10`
	ocsize=`ls -l $file | cut -f5 -d" "`

	globus login

	globus ls -l ${niagEP}:${niagDir} --filter "${bfile}" > ${orionLogDir}/ncfile_${ident}.log 2>&1 

	ncsize=`tail -n 1 ${orionLogDir}/ncfile_${ident}.log | awk '{print $7}'`
	if echo "$ncsize" | grep -qE '^[0-9]+$'; then 
	    if [[ ${ocsize} -eq ${ncsize} ]];then
		rcc=0
		echo "File $file already transferred"
		echo "/bin/rm $file"
		/bin/rm $file
	    else
		echo "File $file need to be transferred due to size"
		rcc=1
	    fi
	else
	    rcc=1
	fi

	if [[ $rcc -gt 0 ]]
	then
	    echo "Transfering $file"
	    globus transfer ${orionEP}:${orionDir}/${file} ${niagEP}:${niagDir}/${bfile} > ${orionLogDir}/o2nc_${ident}.log

	    gID=`tail -n 1 ${orionLogDir}/o2nc_${ident}.log | awk '{print $3}'`
	    echo ${gID}
	    
	    echo "Waiting on 'globus transfer' task '$gID'"
	    globus task wait "${gID}"
	    rcc=$?
	    
	    if [[ $rcc -eq 0 ]];then
		echo "Niagara backup of $file was done successfully!!!!!!"
		echo "/bin/rm $file"
		/bin/rm $file
	    else
		echo "Niagara backup of $file failed at "`date`
	    fi
	fi

    done
else
    echo "No control files to transfer to Niagara"
    rcc=0
fi

ls -1 enkfgdas*/*/*tar > /dev/null 2>&1 
rce=$?

if [[ $rce -eq 0 ]]
then
    efiles=`ls -1 enkfgdas*/*/*tar`
    for file in ${efiles[*]}
    do
	bfile=`basename ${file}`
	ident=`echo $file | tail -c15 | cut -c 1-10`
	oesize=`ls -l $file | cut -f5 -d" "`

	globus login

	globus ls -l ${niagEP}:${niagDir} --filter "${bfile}" > ${orionLogDir}/nefile_${ident}.log 2>&1 

	nesize=`tail -n 1 ${orionLogDir}/nefile_${ident}.log | awk '{print $7}'`
	if echo "$nesize" | grep -qE '^[0-9]+$'; then 
	    if [[ ${oesize} -eq ${nesize} ]];then
		rce=0
		echo "File $file already transferred"
		echo "/bin/rm $file"
		/bin/rm $file
	    else
		echo "File $file need to be transferred due to size"
		rce=1
	    fi
	else
	    rce=1
	fi

	if [[ $rce -gt 0 ]]
	then
	    echo "Transfering $file"
	    globus transfer ${orionEP}:${orionDir}/${file} ${niagEP}:${niagDir}/${bfile} > ${orionLogDir}/o2ne_${ident}.log

	    gID=`tail -n 1 ${orionLogDir}/o2ne_${ident}.log | awk '{print $3}'`
	    echo ${gID}
	    
	    echo "Waiting on 'globus transfer' task '$gID'"
	    globus task wait "${gID}"
	    rce=$?
	    
	    if [[ $rce -eq 0 ]];then
		echo "Niagara backup of $file was done successfully!!!!!!"
		echo "/bin/rm $file"
		/bin/rm $file
	    else
		echo "Niagara backup of $file failed at "`date`
	    fi
	fi

    done
else
    echo "No ensemble files to transfer to Niagara"
    rce=0
fi

