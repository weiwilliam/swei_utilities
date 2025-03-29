#!/usr/bin/env python3
import os,sys
from r2d2 import R2D2Data
import pandas as pd
from datetime import timedelta
from utils import get_dates

fetch = 1
expid = '9badfd'
sdate = '2021082318'
edate = '2021082318'
hint = 6
half_win = timedelta(hours=hint)/2
step = 'PT6H'
obsname = 'viirs_j1_albedo-thinned_p99'
#provider = 'nasa'
file_extension = 'nc4'
savedir = f'/glade/derecho/scratch/swei/Dataset/experiments/{expid}/fb/{obsname}'

if fetch and not os.path.exists(savedir):
    os.makedirs(savedir)

print(f'Search {obsname} for cycle {sdate} to {edate} every {hint} hours from Exp: {expid}')


dates = get_dates(sdate, edate, hint)

result = []
total_conf = []
for date in dates:
    win_beg = (date - half_win).strftime('%Y-%m-%dT%H:%M:00Z')
    date_string = date.strftime('%Y%m%d%H')
    fbfile = os.path.join(savedir,'fb.'+obsname+'.'+date_string+'.'+file_extension)
    conf = {
            'obsname': obsname,
            'window_begin': win_beg,
            'window_length': step,
            'fbfile': fbfile,
            'file_extension':file_extension,
            }
    
    result += R2D2Data.search(
                             experiment=expid,
                             item='feedback',
                             observation_type=conf['obsname'],
                             window_start=conf['window_begin'],
                             window_length=conf['window_length'],
                             )
    total_conf += [conf]
print(result)

for item, cyc_conf in zip(result, total_conf):
    if not fetch:
        continue

    print(f"Fetch {item} to {cyc_conf['fbfile']}")
    R2D2Data.fetch(
        experiment=expid,
        item='feedback',
        observation_type=item['observation_type'],
        window_start=item['window_start'],
        window_length=item['window_length'],
        target_file=cyc_conf['fbfile'],
        file_extension=item['file_extension'],
    )

