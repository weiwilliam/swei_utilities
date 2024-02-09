#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data

savedir='/work2/noaa/jcsda/shihwei/data/geos'
date='20210805T060000Z'
step='PT6H'
filetype='abkg.eta'
model='geos'

outputpath = savedir + '/' + date
if ( not os.path.exists(outputpath) ):
    os.makedirs(outputpath)

R2D2Data.fetch(item='forecast',
    model='geos',
    experiment='oper',
    file_extension='nc',
    resolution='c90',
    file_type=filetype,
    step=step,
    date=date,
    target_file=f'{savedir}/{date}/{model}.{filetype}.{date}.{step}.nc'
)

