#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data
import pandas as pd
from datetime import timedelta

fetch = 1
savedir='/work2/noaa/jcsda/shihwei/save_geoval/input/obs'
date='2021080506'
half_win = timedelta(hours=6)/2
step='PT6H'
win_beg = (pd.to_datetime(date,format='%Y%m%d%H')-half_win).strftime('%Y-%m-%dT%H:00:00Z')
obsname = 'viirs_n20_aod-thinned'
provider = 'noaa'
file_extension = 'nc4'
obsfile = os.path.join(savedir,'obs.'+obsname+'.'+date+'.'+file_extension)

conf = {
        'obsname': obsname,
        'window_begin': win_beg,
        'window_length': step,
        'obsfile': obsfile,
        'file_extension':file_extension,
        }

result = R2D2Data.search(
                        provider=provider,
                        item='observation',
                        observation_type=conf['obsname'],
                        window_start=conf['window_begin'],
                        window_length=conf['window_length'],
                        )

for item in result:
    print(item)
    if not fetch:
        continue

    R2D2Data.fetch(
        provider=provider,
        item='observation',
        observation_type=conf['obsname'],
        window_start=conf['window_begin'],
        window_length=conf['window_length'],
        target_file=conf['obsfile'],
        file_extension=conf['file_extension'],
    )

