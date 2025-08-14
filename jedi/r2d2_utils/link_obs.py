#!/usr/bin/env python3
import os,sys
import r2d2
import pandas as pd
from datetime import timedelta
from utils import get_dates

link = 1
verbose = 0
data_store = '/glade/campaign/mmm/parc/jedipara/r2d2-experiments-nwsc/observation'
parent_savedir = '/glade/derecho/scratch/swei/Dataset/input/obs'
#parent_savedir = '/glade/campaign/ncar/nmmm0072/Data/obs'
sdate = '2024082200'
edate = '2024090100'
hint = 1
half_win = timedelta(hours=hint)/2
step = 'PT1H'
obsname = 'airnow'
provider = 'epa'  # epa, nasa, noaa, esa
file_extension = 'nc4'

savedir = f'{parent_savedir}/{obsname}'
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

if link:
    if not os.path.exists(savedir):
        os.mkdir(savedir)
        os.chmod(savedir, 0o775)
        print(f'Create {savedir} and change it to permission 775')

    for item, cyc_conf in zip(results, total_conf):
        print(f"Link {item} to {cyc_conf['obsfile']}")
    
        tmp_index = item['observation_index']
        tmp_winbeg = item['window_start']
        tmp_format = item['file_extension']
        source_file = f'{data_store}/{tmp_winbeg}/{tmp_index}.{tmp_format}'
    
        if os.path.exists(source_file):
            os.symlink(source_file, cyc_conf['obsfile'])
        else:
            print(f'No such file: {source_file}')
