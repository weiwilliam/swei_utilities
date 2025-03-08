#!/usr/bin/env python3
import sys, re
import argparse
from datetime import datetime
import netCDF4 as nc
import numpy as np
import os
from refdict import ops

def isinside(lat_arr, lon_arr, poly_file):
    import numpy as np
    import pandas as pd
    from shapely.geometry import Point, Polygon
    df = pd.read_csv(poly_file)
    minlat = np.floor(df['Lat'].min()).astype(np.int32) 
    maxlat = np.ceil(df['Lat'].max()).astype(np.int32)
    minlon = np.floor(df['Lon'].min()).astype(np.int32)
    maxlon = np.ceil(df['Lon'].max()).astype(np.int32)
    print(f'min/max lat, min/max lon: {minlat}/{maxlat}, {minlon}/{maxlon}')   

    polygon_coords = list(zip(df['Lat'].values, df['Lon'].values))
    # Create a shapely Polygon object
    polygon = Polygon(polygon_coords)
    out_mask = np.zeros_like(lat_arr, dtype=bool)
    near_mask = ((lat_arr > minlat) & (lat_arr < maxlat) &
                 (lon_arr > minlon) & (lon_arr < maxlon))

    for i, (plat, plon) in enumerate(zip(lat_arr, lon_arr)):
        if near_mask[i]:
            point = Point(plat, plon)
            out_mask[i] = polygon.contains(point)
    del(df)

    return out_mask

class cropioda(object):
    def __init__(self, input, output, polygon, maskbydict):
        src = nc.Dataset(input, 'r')
        if src.dimensions['Location'].size == 0:
            raise Exception('no obs available')

        lat = src.groups['MetaData'].variables['latitude'][:].ravel()
        lon = src.groups['MetaData'].variables['longitude'][:].ravel()
      
        if maskbydict:
            mskgrp = maskbydict['group']
            mskchl = maskbydict['channel'] - 1 
            mskopr = maskbydict['operator']
            mskval = maskbydict['value']
            mskvarn = list(src.groups[mskgrp].variables.keys())[0]
            mskvar = src.groups[mskgrp].variables[mskvarn]
            mskchlindx = mskvar.dimensions.index('Channel')
            indice = [slice(None)] * mskvar.ndim
            indice[mskchlindx] = mskchl
            mask = mskopr(mskvar[tuple(indice)], mskval)
        else:
            mask = isinside(lat, lon, polygon)

        if np.count_nonzero(mask) == 0:
            raise Exception('no obs available in the target area')
        else:
            print(f'{np.count_nonzero(mask)} obs in the target area')

        dst = nc.Dataset(output, 'w')
        dst.setncatts(src.__dict__)

        for name, dimension in src.dimensions.items():
            if name == 'Location':  
                dst.createDimension(name, np.count_nonzero(mask))
            else:
                dst.createDimension(name, len(dimension) if not dimension.isunlimited() else None)

        for name, variable in src.variables.items():
            print(f'Processing {variable}')
            # Define the variable in the new file
            dst_var = dst.createVariable(name, variable.datatype, variable.dimensions)
            # Copy variable attributes
            dst_var.setncatts(variable.__dict__)
            if 'Location' in variable.dimensions:
                indices = [slice(None)] * variable.ndim
                dim_index = variable.dimensions.index('Location')
                indices[dim_index] = mask
                dst_var[:] = variable[tuple(indices)]
            else:
                dst_var[:] = variable[:]

        for grp, group in src.groups.items():
            dst_grp = dst.createGroup(grp)
            for var, variable in src.groups[grp].variables.items():
                print(f'Processing {grp} / {var}')
                dst_var = dst_grp.createVariable(var, variable.datatype, variable.dimensions)
                dst_var.setncatts(variable.__dict__)
                if 'Location' in variable.dimensions:
                    indices = [slice(None)] * variable.ndim
                    dim_index = variable.dimensions.index('Location')
                    indices[dim_index] = mask
                    dst_var[:] = variable[tuple(indices)]
                else:
                    dst_var[:] = variable[:]
                
def main():

    parser = argparse.ArgumentParser(
        description=('Read an IODA file and crop based on lat/lon')
    )
    parser.add_argument(
        '-i', '--input',
        help="path of input ioda file",
        type=str, required=True)
    parser.add_argument(
        '-o', '--output',
        help="name of output ioda file",
        type=str, required=True)
    parser.add_argument(
        '-p', '--polygon',
        help="masking polygon file",
        type=str, default=None)
    parser.add_argument(
        '-m', '--mask_by',
        help="keep data meets the critera",
        type=str, default=None)

    args = parser.parse_args()

    if args.polygon is None and args.mask_by is None:
        raise Exception('at least one masking method needed: polygon/mask_by')

    maskdict = {}
    if args.mask_by:
        pattern = r"(\w+):(\d+)([<>=!]+)([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)"
        match = re.match(pattern, args.mask_by)
        maskdict['group'] = match.group(1)
        maskdict['channel'] = int(match.group(2))
        maskdict['operator'] = ops[match.group(3)]
        if 'QC' in maskdict['group']:
            maskdict['value'] = int(match.group(4))
        else:
            maskdict['value'] = float(match.group(4))

    # Read in the AOD data
    cropped = cropioda(args.input, args.output, args.polygon, maskdict)

if __name__ == '__main__':
    main()
