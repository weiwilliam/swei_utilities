#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data
import pandas as pd
from datetime import timedelta

savedir='/discover/nobackup/swei1/Git/save_geoval/Data/obs'
date='2021081418'
half_win = timedelta(hours=6)/2
step='PT6H'
win_beg = (pd.to_datetime(date,format='%Y%m%d%H')-half_win).strftime('%Y-%m-%dT%H:00:00Z')
obsname = 'viirs_npp_aod-thinned'
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

print(conf)

R2D2Data.fetch(
    provider=provider,
    item='observation',
    observation_type=conf['obsname'],
    window_start=conf['window_begin'],
    window_length=conf['window_length'],
    target_file=conf['obsfile'],
    file_extension=conf['file_extension'],
)

