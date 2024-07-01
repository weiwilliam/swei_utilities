#!/usr/bin/env python3
import sys
import pandas as pd
import numpy as np
from shapely.geometry import Point, Polygon

polyfile = './domain_polygon.csv'
df = pd.read_csv(polyfile)
polygon_coords = list(zip(df['Lat'].values, df['Lon'].values))

#polygon_coords = [tuple(map(float, df['Lat'])) for line in file]

# Create a shapely Polygon object
polygon = Polygon(polygon_coords)

lat = np.array([35., 43., 46.], dtype=np.float32)
lon = np.array([-72, -75., -80.], dtype=np.float32)

mask = np.zeros_like(lat,dtype=bool)

for i, (plat, plon) in enumerate(zip(lat,lon)):
    point = Point(plat, plon)
    mask[i] = polygon.contains(point)

print(lat[mask],lon[mask])

