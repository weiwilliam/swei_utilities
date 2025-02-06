#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data
import pandas as pd
from datetime import timedelta
from utils import get_dates

store = 1
targetdir = '/work2/noaa/jcsda/shihwei/data/jedi-data/input/obs/viirs_j1_albedo-thinned_p99'
sdate = '2021082318'
edate = '2021082318'
hint = 6
half_win = timedelta(hours=hint)/2
step = 'PT6H'
#obsname = 'tropomi_s5p_co_total'
obsname = 'viirs_j1_albedo-thinned_p99'
provider = 'nasa' # 'nasa, esa'
file_extension = 'nc4'

print(f'Search {obsname} for cycle {sdate} to {edate} every {hint} hours from Provider: {provider}')


dates = get_dates(sdate, edate, 6)

result = []
total_conf = []

for date in dates:
    win_beg = (date - half_win).strftime('%Y-%m-%dT%H:00:00Z')
    date_string = date.strftime('%Y%m%d%H')
    obsfile = os.path.join(targetdir,'obs.'+step+'.'+obsname+'.'+date_string+'.'+file_extension)
    conf = {
            'obsname': obsname,
            'window_begin': win_beg,
            'window_length': step,
            'obsfile': obsfile,
            'file_extension':file_extension,
            }
    
    result += R2D2Data.search(
                  provider=provider,
                  item='observation',
                  observation_type=conf['obsname'],
                  window_start=conf['window_begin'],
                  window_length=conf['window_length'],
              )
    total_conf += [conf]

for item in result:
    print(item)

if store:
    for cyc_conf in total_conf: 
        ioda_file = cyc_conf['obsfile']
        if not os.path.exists(ioda_file):
            print(f'{ioda_file} does not exist')
            continue

        R2D2Data.store(
            item='observation',
            provider=provider,
            observation_type=cyc_conf['obsname'],
            file_extension='nc4',
            window_start=cyc_conf['window_begin'],
            window_length=cyc_conf['window_length'],
            source_file=ioda_file
        )

