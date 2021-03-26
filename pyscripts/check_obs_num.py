import os
import xarray as xa
import numpy as np

diag_path='/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/SingleRadTest/rundir2'
sensor_id='iasi_metop-a'
loop_id='01'

nobs=0
for pe_n in np.arange(160):
   dirname='dir.%4.4i'%(pe_n)
   dirpath=diag_path+'/'+dirname
   raddfile=dirpath+'/'+sensor_id+'_'+loop_id+'.nc4'
   if (os.path.exists(raddfile)):
      print(raddfile)
      ds=xa.open_dataset(raddfile)
      if (hasattr(ds,'nobs')):
         npts=int(ds.nobs.size/ds.nchans.size)
         nchs=ds.nchans.size
         nobs=nobs+npts
         del(nchs,npts)

print('Total Obs= %i'%(nobs))
