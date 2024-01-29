#!/usr/bin/env python3
import os,sys
r2d2dir = '/work2/noaa/jcsda/shihwei/skylab/jedi-bundle/r2d2/src/r2d2'
os.environ["PYTHONPATH"] = r2d2dir + ':' + os.environ["PYTHONPATH"]
from r2d2 import R2D2Data

date = '20210805T060000Z'
resolution = 'c90'
member = R2D2Data.DEFAULT_INT_VALUE
print(member)

resultlist=R2D2Data.search(
    item='forecast',
    model='geos',
    experiment='oper',
    file_extension='nc',
    resolution=resolution,
    file_type='abkg.eta',
    #file_type='bkg_clcv',
    step='PT6H',
    date=date,
    member=member,
)

print(resultlist)
