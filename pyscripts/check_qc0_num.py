import xarray as xa
import numpy as np

datapath='/scratch1/BMC/gsd-fv3-dev/Shih-wei.Wei/SingleRadTest/OUTPUT'
expname='ctl5k_nch202'
cdate=2020062212
sensor='iasi_metop-a'
loop='ges'

# diag_iasi_metop-a_ges.2020062212.nc4

diagfile='%s/%s/%s/diag_%s_%s.%s.nc4' %(datapath,expname,str(cdate),sensor,loop,str(cdate))
print('Diag File: %s'%(diagfile))

ds=xa.open_dataset(diagfile)

qcflags=ds.QC_Flag
qc0msk=(qcflags==0)
qc0idx=qc0msk.argmax()

print('qc0 counts = %i' %(np.count_nonzero(qc0msk)))
