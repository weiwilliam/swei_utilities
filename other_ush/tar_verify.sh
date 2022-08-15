#!/bin/ksh

verify_outpath=/scratch/users/swei/verif_global_pcp_step2/tmpnwdev/verif_global.49093
verify_type_list="precip_step2"
#verify_type_list="grid2grid_step2 grid2obs_step2 precip_step2"
tarball_savedir=/data/users/swei/archive/metplus_data

for vtype in $verify_type_list
do
  if [ -s $verify_outpath/$vtype ]; then
     image_savedir=$verify_outpath/$vtype/metplus_output/images
     echo "Creating tarball of $vtype"
     case $vtype in
     'grid2grid_step2')
         tag='g2g'
         cd $verify_outpath/$vtype
         tar -cf $tarball_savedir/scorecard.tar ./scorecard
     ;;
     'grid2obs_step2')
         tag='g2o'
     ;;
     'precip_step2')
         tag='pcp'
         #tar -cvhf $tarball_savedir/verify_pcp.tar $image_savedir/*.png
     ;;
     esac
     cd $image_savedir
     find ./ -type l -name "*.png" -print > $tarball_savedir/tmplist
     echo `wc -l $tarball_savedir/tmplist`
     tar -chf $tarball_savedir/verify_${tag}.tar -T $tarball_savedir/tmplist
  else
     echo "$vtype is not available"
  fi
done
