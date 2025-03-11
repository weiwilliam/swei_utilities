#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data
import pandas as pd
from datetime import timedelta
from utils import get_dates

r2d2store_dir = '/data/prod/jedi/r2d2-experiments-ssec/observation' #20240827T173000Z
savedir = '/data/users/swei/Dataset/jedi-data/input/obs/tempo_no2_tropo-full'
sdate = '2024082200'
edate = '2024083118'
hint = 1
half_win = timedelta(hours=hint)/2
step = 'PT1H'
#win_beg = (pd.to_datetime(date,format='%Y%m%d%H')-half_win).strftime('%Y-%m-%dT%H:00:00Z')
obsname = 'tempo_no2_tropo'
provider = 'nasa'
file_extension = 'nc4'

print(f'Search {obsname} for cycle {sdate} to {edate} every {hint} hours from Provider: {provider}')


dates = get_dates(sdate, edate, hint)

result = []
total_conf = []
for date in dates:
    win_beg = (date - half_win).strftime('%Y-%m-%dT%H:%M:00Z')
    date_string = date.strftime('%Y%m%d%H')
    obsfile = os.path.join(savedir,'obs.'+obsname+'.'+date_string+'.'+file_extension)
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

    target_obs = os.path.join(r2d2store_dir, date.strftime('%Y%m%dT%H%M%SZ'), result['observation_index'])
    if os.exists(


