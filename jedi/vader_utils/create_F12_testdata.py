#!/usr/bin/env python3
#
# Convert WRF-Chem to Vader testinput data.
#
import netCDF4 as nc

in_wrfdata = './wrfout_d01_20240117_180000.nc'
resol = 'F12'
if resol == 'F12':
    nx = 48; ny = 24

vars_dict = {'QVAPOR':'humidity_mixing_ratio_kgkg',
             'PB': 'base_air_pressure',
             'P': 'perturbation_air_pressure',
             'T': 'perturbation_air_potential_temperature',
             'sulf': 'sulfate_ppmv',
            }

ncd = nc.Dataset(in_wrfdata,'r')
