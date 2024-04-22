#!/usr/bin/env python

import Ngl
import numpy as np
from netCDF4 import Dataset
import math
import sys


if __name__ == "__main__":

    #
    # Get the name of the file containing the static information
    #
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print('')
        print('Usage: '+sys.argv[0]+' [mesh filename] <field filename>')
        print('')
        exit(0)

    #
    # The (lat,lon) the plot is to be centered over
    #
    cenLat   = 0.0
    cenLon   = 0.0

    #
    # Projection to use for plot
    #
    projection = 'CylindricalEquidistant'


    r2d = 180.0 / math.pi             # radians to degrees

    if len(sys.argv) == 2:
        f = Dataset(sys.argv[1])
        g = f
    elif len(sys.argv) == 3:
        f = Dataset(sys.argv[2])
        g = Dataset(sys.argv[1])

    rlist = Ngl.Resources()
#    rlist.wkWidth = 1200
#    rlist.wkHeight = 1200

    rlist.wkColorMap = 'gui_default'

    wks_type = 'png'
    wks = Ngl.open_wks(wks_type, 'delta_sst', rlist)

    lonCell = g.variables['lonCell'][:] * r2d
    latCell = g.variables['latCell'][:] * r2d

    res = Ngl.Resources()

    res.sfXArray             = lonCell
    res.sfYArray             = latCell

    res.cnFillMode           = 'AreaFill'

    res.cnFillOn             = True
    res.cnLinesOn            = False
    res.cnLineLabelsOn       = False

    res.cnInfoLabelOn        = True

    res.lbLabelAutoStride    = True
    res.lbBoxLinesOn         = False

    res.mpProjection      = projection
    res.mpDataBaseVersion = 'MediumRes'
    res.mpCenterLatF      = cenLat
    res.mpCenterLonF      = cenLon
    res.mpGridAndLimbOn   = True
    res.mpGridAndLimbDrawOrder = 'PreDraw'
    res.mpGridLineColor   = 'Background'
    res.mpOutlineOn       = True
    res.mpDataBaseVersion = 'Ncarg4_1'
    res.mpDataSetName     = 'Earth..3'
    res.mpOutlineBoundarySets = 'Geophysical'
    res.mpPerimOn         = True
    res.mpLimitMode = 'LatLon'
    res.mpMinLonF = -180.0
    res.mpMaxLonF = 180.0
    res.mpMinLatF = -90.0
    res.mpMaxLatF = 90.0

    res.cnLevelSelectionMode = 'ManualLevels'
    res.cnMinLevelValF = -2.0
    res.cnMaxLevelValF = 2.0
    res.cnLevelSpacingF = 0.10
    res.lbAutoManage = False
    res.lbOrientation = 'Horizontal'
    res.lbBoxEndCapStyle = 'TriangleBothEnds'
    res.lbLabelAngleF = 90.0
    res.lbLabelFontHeightF = 0.01

    res.mpFillOn              = True            # Turn on map fill.
    res.mpFillAreaSpecifiers  = ['Land']
    res.mpSpecifiedFillColors = [0]
    res.mpAreaMaskingOn       = True            # Indicate we want to 
    res.mpMaskAreaSpecifiers  = ['Water']
    res.cnFillDrawOrder       = 'Predraw'       # Draw contours first.

    fld = f.variables['sst'][10,:] - f.variables['sst'][0,:]
    map = Ngl.contour_map(wks, fld, res)

    Ngl.end()
