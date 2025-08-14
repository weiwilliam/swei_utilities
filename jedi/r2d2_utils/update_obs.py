#!/usr/bin/env python3
import os,sys
import r2d2
import pandas as pd
from datetime import timedelta
from utils import get_dates

update = 1
savedir = '/glade/derecho/scratch/swei/Dataset/input/obs/modis_aqua_aod-full'
sdate = '2024110100'
edate = '2024110100'
hint = 6
half_win = timedelta(hours=hint)/2
step = 'PT6H'
#win_beg = (pd.to_datetime(date,format='%Y%m%d%H')-half_win).strftime('%Y-%m-%dT%H:00:00Z')
obsname = 'pace_aod'
provider = 'noaa'
file_extension = 'nc4'
key2update = 'provider'
update2val = 'nasa'

if not os.path.exists(savedir):
    os.mkdir(savedir)

print(f'Search {obsname} for cycle {sdate} to {edate} every {hint} hours from Provider: {provider}')

dates = get_dates(sdate, edate, hint)

result = []
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
    
    result += r2d2.search(
                  provider=provider,
                  item='observation',
                  observation_type=conf['obsname'],
                  window_start=conf['window_begin'],
                  window_length=conf['window_length'],
              )
    total_conf += [conf]
print(result)

if update:
    for item, cyc_conf in zip(result, total_conf):
        print(f"Update {key2update} to {update2val} in {item}")
    
        r2d2.update_by_index(
            item='observation',
            index=int(item['observation_index']),
            key=key2update,
            value=update2val,
        )

