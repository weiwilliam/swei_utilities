#!/usr/bin/env python3
import os, sys
import argparse
from pathlib import Path
import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import matplotlib.colors as mpcrs
import cartopy.crs as ccrs
from cartopy.mpl.ticker import LongitudeFormatter, LatitudeFormatter

from utils import setup_cmap
from plot_utils import set_size

class read_ioda(object):
    def __init__(self, in_dict):
        self.iodafile = in_dict['iodafile']
        self.varname = in_dict['varname']

        dims_ds = xr.open_dataset(self.iodafile)
        channel = dims_ds.Channel.values

        meta_ds = xr.open_dataset(self.iodafile,group='MetaData')
        lons = meta_ds.longitude
        lats = meta_ds.latitude

        group_list = ['ObsValue', 'ObsError', 'hofx0', 'hofx1', 'oman', 'ombg']

        print(f'Varname= {self.varname}')
        for grp in group_list:
            data_ds = xr.open_dataset(self.iodafile,group=grp)
            data_ds = data_ds.assign_coords(Channel=channel.astype(np.int32))
            data = data_ds[self.varname]
            max = data.max(skipna=True)
            min = data.min(skipna=True)
            print(f'group {grp}: Max= {max}, Min= {min}')

            data_ds.close()

        meta_ds.close()

if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description=('Read NASA VIIRS M-band Level 1b file(s) and Converter'
                     ' of native NetCDF format for observations of TOA reflectance'
                     ' from VIIRS to IODA NetCDF format.')
    )
    parser.add_argument(
        '-i', '--iodafile',
        help="path of ioda file",
        type=str, required=True)

    parser.add_argument(
        '-v', '--varname',
        help="variable name of ioda file",
        type=str, required=True)

    args = parser.parse_args()
    
    in_dict = {'iodafile': args.iodafile,
               'varname': args.varname,
               }

    print(in_dict)

    read_ioda(in_dict) 

