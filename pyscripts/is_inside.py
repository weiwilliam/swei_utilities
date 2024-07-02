#!/usr/bin/env python3
import sys
import pandas as pd
import numpy as np
from shapely.geometry import Point, Polygon

def isinside(lat_arr, lon_arr, poly_file):
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


polyfile = '/data/users/swei/Git/JEDI/JEDI-METplus/etc/polygons/wxaq_polygon.csv'
lat = np.array([35., 43., 46.], dtype=np.float32)
lon = np.array([-72, -75., -80.], dtype=np.float32)

mask1 = isinside(lat, lon, polyfile)
print(lat[mask1],lon[mask1])

df = pd.read_csv(polyfile)
polygon_coords = list(zip(df['Lat'].values, df['Lon'].values))
#
##polygon_coords = [tuple(map(float, df['Lat'])) for line in file]
#
## Create a shapely Polygon object
polygon = Polygon(polygon_coords)
#
#
mask = np.zeros_like(lat,dtype=bool)
#
for i, (plat, plon) in enumerate(zip(lat,lon)):
    point = Point(plat, plon)
    mask[i] = polygon.contains(point)

print(lat[mask],lon[mask])

