#!/usr/bin/env python3
import os,sys
import r2d2
import pandas as pd
from datetime import timedelta
from utils import get_dates

fetch = 1
verbose = 0
savedir = '/glade/derecho/scratch/swei/Dataset/input/obs/modis_aqua_aod-full'
sdate = '2024110106'
edate = '2024110106'
hint = 6
half_win = timedelta(hours=hint)/2
step = 'PT6H'
#win_beg = (pd.to_datetime(date,format='%Y%m%d%H')-half_win).strftime('%Y-%m-%dT%H:00:00Z')
obsname = 'modis_aqua_aod'
provider = 'nasa' # 'nasa'
file_extension = 'nc4'

if not os.path.exists(savedir):
    os.mkdir(savedir)

print(f'Search {obsname} for cycle {sdate} to {edate} every {hint} hours from Provider: {provider}')

dates = get_dates(sdate, edate, hint)

results = []
total_conf = []
for date in dates:
    win_beg = (date - half_win).strftime('%Y%m%dT%H%M%SZ')
    date_string = date.strftime('%Y%m%d%H')
    obsfile = os.path.join(savedir,'obs.'+obsname+'.'+date_string+'.'+file_extension)
    conf = {
            'obsname': obsname,
            'window_begin': win_beg,
            'window_length': step,
            'obsfile': obsfile,
            'file_extension':file_extension,
            }
    
    result = r2d2.search(
                 provider=provider,
                 item='observation',
                 observation_type=conf['obsname'],
                 window_start=conf['window_begin'],
                 window_length=conf['window_length'],
             )
    if result:
        results += result
        total_conf += [conf]
if verbose: print(results)

for item, cyc_conf in zip(results, total_conf):
    print(f"Fetch {item} to {cyc_conf['obsfile']}")
    if not fetch:
        continue

    r2d2.fetch(
        provider=item['provider'],
        item='observation',
        observation_type=item['observation_type'],
        window_start=item['window_start'],
        window_length=item['window_length'],
        target_file=cyc_conf['obsfile'],
        file_extension=item['file_extension'],
    )

