#!/bin/ksh

if [ -d /glade ]; then
   machine='cas'
   batchrun='N'
elif [ -d /carddata ]; then
   machine='s4'
   batchrun='Y'  
elif [ -d /scratch1 ]; then
   machine='hera'
   batchrun='Y'  
fi

if [ $machine == 'hera' ]; then
   module purge
   module load intel/2022.1.2
   module use /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
   module load nemsio/2.2.4 bacio/2.0.3 sp/2.0.3 w3nco/2.0.7 netcdf_parallel/4.7.5
   module load prod_util/1.1.0
   module list
   nemsio2nc_util=/home/Shih-wei.Wei/utils/nemsio_util/nemsio2nc.fd
   nemsatm2nc=${nemsio2nc_util}/nemsioatm2nc
   nemssfc2nc=${nemsio2nc_util}/nemsiosfc2nc
   aprun=`which srun`
   accnt='gsd-fv3-dev'
   wtime='01:00:00'
   qos='batch'
   part='serial'
   outfile=/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/wrklog/gefs_nems2nc.log
elif [ $machine == 's4' ]; then
   module load license_intel/S4
   module load intel/18.0.4
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

if [ -s $nemsatm2nc ]; then
   if [ $batchrun == 'Y' ]; then
      if [ ! -z $atm_in ] ; then
         if [ -s $atm_in -a ! -s $atm_out ]; then
            $aprun -n 1 -A $accnt -t $wtime -o $outfile $nemsatm2nc $atm_in $atm_out &
         fi
      fi
   else
      [[ ! -s $atm_out ]] && $nemsatm2nc $atm_in $atm_out
   fi
else
   echo 'nemsioatm2nc not existed!!'
fi
if [ -s $nemssfc2nc ]; then
   if [ $batchrun == 'Y' ]; then
      if [ ! -z $sfc_in ]; then
         if [ -s $sfc_in -a ! -s $sfc_out ]; then
            $aprun -n 1 -A $accnt -t $wtime -o $outfile $nemssfc2nc $sfc_in $sfc_out $nst_in &
         fi
      fi
   else
      [[ ! -s $sfc_out ]] && $nemssfc2nc $sfc_in $sfc_out $nst_in
   fi
else
   echo 'nemsiosfc2nc not existed!!'
fi
