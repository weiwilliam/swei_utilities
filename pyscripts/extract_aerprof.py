#!/usr/bin/env python
import sys
import xarray as xa
import numpy as np
import matplotlib.pyplot as plt

'''
Usage: extract_aerprof.py [3D NetCDF file] [aerosol name] [lat] [lon] [output prefix]

1. Select Lat/Lon, find the nearest grid point
2. Calculate the layer pressure and convert the mixing ratio
   to concentration (mass density) for CRTM with ugkg_kgm2 or kgkg_kgm2
3. Output the profile in the format below:
   aerosol name   |   number of levels
   layer pressure |   aerosol concentration
   Layer pressure and aerosol concentration have to be top to bottom.
'''

grav=9.80665e+0


argnum=len(sys.argv)
print(sys.argv)
if (argnum-1 != 5):
   print('Number of arguments must be 5')
   print('Usage: extract_aerprof.py [3D NetCDF file] [aerosol name] [lat] [lon] [output prefix]')
   sys.exit()

ncfile=str(sys.argv[1])
aername=str(sys.argv[2])
sel_lat=float(sys.argv[3])
sel_lon=float(sys.argv[4])
prefix=str(sys.argv[5])

ds=xa.open_dataset(ncfile)

print('Prepare the profile at Lat:%f Lon:%f for %s in %s'
      %(sel_lat,sel_lon,aername,ncfile))
prof=ds.sel(lat=sel_lat,lon=sel_lon,method='nearest')

plat=prof.lat.values
if (plat >= 0.):
   ns='N'
else:
   ns='S'

plon=prof.lon.values
if (plon >= 0.):
   we='E'
else:
   we='W'

aerlevs=prof.lev.size
delp=prof.DELP[0].values

pres=np.zeros((prof.lev.size),dtype='float')
for k in np.arange(prof.lev.size):
    if (k == 0):
       base=1.
    else:
       base=l_p
    u_p=base
    l_p=base+delp[k]
    pres[k]=np.exp((np.log(u_p)+np.log(l_p))/2)
aerpres=pres

'''
aerpres=np.array((     1.,     2.,   3.27,   4.76,   6.60,   8.93,  11.97,  15.95,  21.13,  27.85,
                     36.5,  47.58,  61.68,  79.51, 101.94, 130.05, 165.08, 208.50, 262.02, 327.64,
                   407.66, 504.68, 621.68, 761.98, 929.29,1127.69,1364.34,1645.71,1979.16,2373.04,
                  2836.78,3381.00,4017.54,4764.39,5638.79,6660.34,7851.23,9236.57,10866.3,12783.7,
                  15039.3,17693.0,20815.2,24487.5,28808.3,33750.0,37500.0,41250.0,45000.0,48750.0,
                  52500.0,56250.0,60000.0,63750.0,67500.0,70000.0,72500.0,75000.0,77500.0,80000.0,
                  82000.0,83500.0,85000.0,86500.0,88000.0,89500.0,91000.0,92500.0,94000.0,95500.0,
                  97000.0,98500.0),dtype='float')
'''

aermr=prof[aername][0].values
kgkg_kgm2=delp/grav
aerconc=aermr*kgkg_kgm2

outputfilename='%s_%s_%.2f%s_%.2f%s.txt' %(prefix,aername,abs(plat),ns,abs(plon),we)
outputfile=open(outputfilename,'w')
outputfile.write('%s %i \n'%(aername,aerlevs))
for k in np.arange(aerlevs):
    # CRTM use hPa as the units for pressure coordinates
    outputfile.write('%.5e %.5e \n' %(aerpres[k]/100.,aerconc[k])) 
outputfile.close()

fig=plt.figure(figsize=(5,8))
ax=plt.subplot()
ax.invert_yaxis()
ax.plot(aerconc,aerpres/100.,'o-')
#ax.legend(aername)
ax.set_xlabel('Concentration [kg/m2]')
ax.set_ylabel('Pressure[hPa]')
ax.ticklabel_format(axis="x", style="sci", scilimits=(0,0))
ax.grid()
ax.set_title('%s_%.2f%s_%.2f%s (%.3e)' %(aername,abs(plat),ns,abs(plon),we,np.sum(aerconc)),loc='left')
fig.savefig('%s_%s_%.2f%s_%.2f%s.png' %(prefix,aername,abs(plat),ns,abs(plon),we))
plt.close()
