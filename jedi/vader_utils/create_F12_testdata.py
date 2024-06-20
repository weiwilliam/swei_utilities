#!/usr/bin/env python3
#
# Convert WRF-Chem to Vader testinput data.
#
import netCDF4 as nc
import numpy as np

in_wrfdata = './wrfout_d01_20240117_180000.nc'
resol = 'F12'
if resol == 'F12':
    nx = 48; ny = 24
missing_val = 9.969209968386869e+36

outpath = '/data/users/swei/Dataset/Wx-AQ/wrfgsi.out.2024011718'
outfile = '%s/%s_%s.nc' % (outpath, 'wrfchem', resol)

xdim_name = 'west_east'
ydim_name = 'south_north'

vars_dict = {'QVAPOR':'humidity_mixing_ratio_kgkg',
             'PB': 'base_air_pressure',
             'P': 'perturbation_air_pressure',
             'T': 'perturbation_air_potential_temperature',
             'sulf': 'sulfate_ppmv',
            }

ncd = nc.Dataset(in_wrfdata,'r')
nz = ncd.dimensions['bottom_top'].size

ncout = nc.Dataset(outfile, 'w', format='NETCDF4')
ncout.createDimension('nx', nx)
ncout.createDimension('ny', ny)

for i, var in enumerate(vars_dict):
    print(var, vars_dict[var])
    tmparr = ncd.variables[var][:].data
    if i==0:
        nxdim = tmparr.shape[3]
        nydim = tmparr.shape[2]
        nx_idx = np.random.choice(np.arange(nxdim), nx, replace=False)
        ny_idx = np.random.choice(np.arange(nydim), ny, replace=False)
    zdim_name = '%s_%s' %('nz', vars_dict[var])
    ncout.createDimension(zdim_name, nz)
   
    outarr = ncout.createVariable(vars_dict[var], 'f4', (zdim_name, 'ny', 'nx')) 
    outarr.fill_value = missing_val
    for ny, y in enumerate(ny_idx):
        outarr[:, ny, :] = tmparr[0, :, y, nx_idx]
    
ncout.close()
