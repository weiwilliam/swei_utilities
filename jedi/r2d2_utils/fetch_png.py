#!/usr/bin/env python3
import os,sys
import r2d2
import pandas as pd
from datetime import timedelta
from utils import get_dates

fetch = 1
verbose = 0
savepath = '/glade/campaign/ncar/nmmm0072/Data/plots/obs'
sdate = '2024110100'
#edate = '2024110100'
edate = '2024113018'
hint = 6
half_win = timedelta(hours=hint)/2
step = 'PT6H'
obstype_list = [
#    'modis_aqua_aod',
#    'modis_terra_aod',
#    'pace_aod',
#    'viirs_aod_db_n20',
#    'viirs_aod_db_npp',
#    'viirs_aod_dt_n20',
#    'viirs_aod_dt_npp',
    'aeronet_aod',
]
expid = '98d9cc'
variable = 'obs_aerosolOpticalDepth'
plot_type = 'map'
file_extension = 'png'


dates = get_dates(sdate, edate, hint)

for obstype in obstype_list:
    print(f'Search {obstype} for cycle {sdate} to {edate} every {hint} hours from experiment: {expid}')
    savedir = f'{savepath}/{obstype}'
    results = []
    total_conf = []
    for date in dates:
        win_beg = (date - half_win).strftime('%Y%m%dT%H%M%SZ')
        date_string = date.strftime('%Y%m%d%H')
        desfile = os.path.join(savedir,'obs.'+obstype+'.'+date_string+'.'+file_extension)
        conf = {
                'obstype': obstype,
                'window_begin': win_beg,
                'window_length': step,
                'desfile': desfile,
                'file_extension':file_extension,
                }
        
        result = r2d2.search(
                     item='media',
                     experiment=expid,
                     observation_type=conf['obstype'],
                     window_start=conf['window_begin'],
                     window_length=conf['window_length'],
                     variable=variable,
                     plot_type=plot_type,
                     file_extension=file_extension,
                 )
        if result:
            results += result
            total_conf += [conf]
    if verbose: print(results)
    
    if fetch:
        if not os.path.exists(savedir):
            os.makedirs(savedir)
            os.chmod(savedir, 0o775)
            print(f'Create {savedir} and change it to permission 775')
    
        for item, cyc_conf in zip(results, total_conf):
            print(f"Fetch {item} to {cyc_conf['desfile']}")
        
            r2d2.fetch(
                item='media',
                experiment=expid,
                observation_type=item['observation_type'],
                window_start=item['window_start'],
                window_length=item['window_length'],
                file_extension=item['file_extension'],
                variable=variable,
                plot_type=plot_type,
                target_file=cyc_conf['desfile'],
            )

