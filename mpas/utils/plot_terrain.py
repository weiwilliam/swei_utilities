#!/usr/bin/env python 

import Ngl
import numpy as np
from netCDF4 import Dataset
import math
from MPASUtils import val_to_index, fill_voronoi_cells, terrain_colormap
import sys


def ter_colors(iCell):
    """
    Define custom mapping of terrain values to colors in the color map

    Variables that need to be defined in the dyanmic scope of this function:
     - ivgtyp   : the vegetation class
     - cnLevels : the color levels
     - nColors  : the number of color levels
     - ter      : The terrain field
    """

    if ivgtyp[iCell] == 17:
        return 4
    else:
        return val_to_index(cnLevels, nColors, ter[iCell]) + 5


if __name__ == "__main__":

    #
    # Get the name of the file containing the static information
    #
    if len(sys.argv) != 2:
        print('')
        print('Usage: '+sys.argv[0]+' <filename>')
        print('')
        exit(0)

    #
    # Center latitude and longitude
    #
    cenlat = 0.0
    cenlon = 0.0
 

    #
    # Set plotting window
    #
    mapLeft   = -180.0
    mapRight  =  180.0
    mapBottom =  -90.0
    mapTop    =   90.0

    g = Dataset(sys.argv[1])

    #
    # The field to be plotted
    #
    ter = g.variables['ter'][:]            # Terrain height
    ivgtyp = g.variables['ivgtyp'][:]    # Vegetation type


    r2d = 180.0 / math.pi             # radians to degrees

    rlist = Ngl.Resources()
#    rlist.wkWidth = 1200
#    rlist.wkHeight = 1200

    wks_type = 'png'
    wks = Ngl.open_wks(wks_type,'terrain',rlist)
    Ngl.define_colormap(wks, terrain_colormap)

    nColors = 98
    cnLevels = np.linspace(0.0, 4000.0, nColors+1)
    nLevels = len(cnLevels)
    nIntervals = nLevels - 1

    nEdgesOnCell = g.variables['nEdgesOnCell'][:]
    verticesOnCell = g.variables['verticesOnCell'][:]
    verticesOnEdge = g.variables['verticesOnEdge'][:]
    x   = g.variables['lonCell'][:] * r2d
    y   = g.variables['latCell'][:] * r2d
    lonCell = g.variables['lonCell'][:] * r2d
    latCell = g.variables['latCell'][:] * r2d
    lonVertex = g.variables['lonVertex'][:] * r2d
    latVertex = g.variables['latVertex'][:] * r2d

    res = Ngl.Resources()

    res.nglPaperOrientation  = 'portrait'

    res.mpProjection      = 'CylindricalEquidistant'
    res.mpDataBaseVersion = 'MediumRes'
    res.mpCenterLatF      = cenlat
    res.mpCenterLonF      = cenlon
    res.mpGridAndLimbOn   = False
    res.mpOutlineOn       = False
    res.mpFillOn          = True
    res.mpPerimOn         = False
    res.nglFrame          = False
    res.mpLimitMode      = 'LatLon'
    res.mpMinLonF        = mapLeft
    res.mpMaxLonF        = mapRight
    res.mpMinLatF        = mapBottom
    res.mpMaxLatF        = mapTop
    res.mpOceanFillColor  = 2
    res.mpInlandWaterFillColor  = 2
    res.mpLandFillColor  = 3

    #
    # Set field name and units
    #
#    res.nglLeftString   = 'blah_long_name'
#    res.nglRightString  = '['+'blah_units'+']'
#    res.tiMainString    = 'arctic.init.nc'


    nCells = len(g.dimensions['nCells'])
    maxEdges = len(g.dimensions['maxEdges'])

    #
    # The purpose of this next line is simply to set up a graphic ('map')
    #    that uses the projection specified above, and over which we
    #    can draw polygons
    #
    map = Ngl.map(wks,res)


    cres = Ngl.Resources()
    cres.txFontColor = 0        # background color
    cres.txFontHeightF = 0.025


    #
    # Draw polygons for cells
    #
    fill_voronoi_cells(wks, map, cnLevels, nColors, nEdgesOnCell, lonVertex, latVertex, verticesOnCell, ter, ter_colors)
    Ngl.draw(map)


    #
    # Draw map outline
    #
    mres = Ngl.Resources()
    mres.mpProjection      = 'CylindricalEquidistant'
    mres.mpCenterLatF      = cenlat
    mres.mpCenterLonF      = cenlon
    mres.mpGridAndLimbOn   = False
    mres.mpOutlineOn       = True
    mres.mpFillOn          = False
    mres.mpPerimOn         = False
    mres.nglFrame          = False
    mres.mpLimitMode       = 'LatLon'
    mres.mpMinLonF         = mapLeft
    mres.mpMaxLonF         = mapRight
    mres.mpMinLatF         = mapBottom
    mres.mpMaxLatF         = mapTop
    mres.mpDataBaseVersion = 'MediumRes'
    mres.mpOutlineBoundarySets = 'GeophysicalAndUSStates'
    mapo = Ngl.map(wks,mres)

    Ngl.frame(wks)

    Ngl.end()
