#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data
import pandas as pd
from datetime import timedelta
from utils import get_dates

fetch = 1
savedir = '/data/users/swei/Dataset/jedi-data/input/obs/tempo_no2_tropo-full'
sdate = '2024061000'
edate = '2024063018'
hint = 6
half_win = timedelta(hours=hint)/2
step = 'PT6H'
#win_beg = (pd.to_datetime(date,format='%Y%m%d%H')-half_win).strftime('%Y-%m-%dT%H:00:00Z')
#obsname = 'tropomi_s5p_co_total'
obsname = 'tempo_no2_tropo'
provider = 'nasa'
file_extension = 'nc4'

print(f'Search {obsname} for cycle {sdate} to {edate} every {hint} hours from Provider: {provider}')


dates = get_dates(sdate, edate, 6)

result = []
total_conf = []
for date in dates:
    win_beg = (date - half_win).strftime('%Y-%m-%dT%H:00:00Z')
    date_string = date.strftime('%Y%m%d%H')
    obsfile = os.path.join(savedir,'obs.'+obsname+'.'+date_string+'.'+file_extension)
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

for item, cyc_conf in zip(result, total_conf):
    print(f"Fetch {item} to {cyc_conf['obsfile']}")
    if not fetch:
        continue

    R2D2Data.fetch(
        provider=item['provider'],
        item='observation',
        observation_type=item['observation_type'],
        window_start=item['window_start'],
        window_length=item['window_length'],
        target_file=cyc_conf['obsfile'],
        file_extension=item['file_extension'],
    )

