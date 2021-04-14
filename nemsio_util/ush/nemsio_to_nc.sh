#!/bin/ksh

machine='s4'
batchrun='Y'  

if [ $machine == 'hera' ]; then
   nems2nc=/scratch1/BMC/gsd-fv3-dev/MAPP_2018/bhuang/JEDI-2020/JEDI-FV3/expCodes/GSDChem_cycling/global-workflow/sorc/nemsio2nc.fd_Cory/nemsioatm2nc
elif [ $machine == 's4' ]; then
   module load license_intel/S4
   module load intel/18.0.3
   module load emc-hpc-stack/2020-q3
   module load hdf5/1.10.6
   module load netcdf/4.7.4
   module load bacio/2.4.1
   module load nemsio/2.5.2
   module load w3nco/2.4.1
   nemsatm2nc=/home/swei/bin/nemsioatm2nc
   nemssfc2nc=/home/swei/bin/nemsiosfc2nc
   aprun=`which srun`
   accnt='star'
   wtime='00:30:00'
   qos='debug'
   part='serial'
   outfile=/data/users/swei/tmp/log.nems2nc
elif [ $machine == 'cas' -o $machine == 'chy' ]; then
   homebin=/glade/u/home/swei/bin
   nemsatm2nc=$homebin/nemsioatm2nc
   nemssfc2nc=$homebin/nemsiosfc2nc
   aprun='qsub'
fi

atm_in=$1
atm_out=$2
sfc_in=$3
sfc_out=$4
nst_in=$5

if [ -s $nemsatm2nc -a -s $nemssfc2nc ]; then
   if [ $batchrun == 'Y' ]; then
      if [ ! -z $atm_in ] ; then
         if [ -s $atm_in -a ! -s $atm_out ]; then
            $aprun -n 1 -A $accnt -t $wtime -o $outfile $nemsatm2nc $atm_in $atm_out &
         fi
      fi
      if [ ! -z $sfc_in ]; then
         if [ -s $sfc_in -a ! -s $sfc_out ]; then
            $aprun -n 1 -A $accnt -t $wtime -o $outfile $nemssfc2nc $sfc_in $sfc_out $nst_in &
         fi
      fi
   else
      [[ ! -s $atm_out ]] && $nemsatm2nc $atm_in $atm_out
      [[ ! -s $sfc_out ]] && $nemssfc2nc $sfc_in $sfc_out $nst_in
   fi
else
   echo 'nemsioatm2nc not existed!!'
fi
