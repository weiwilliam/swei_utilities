#!/usr/bin/env python3
import os,sys
import pandas as pd
from datetime import timedelta
from r2d2 import R2D2Data

member = R2D2Data.DEFAULT_INT_VALUE

fetch = 0
savedir = '/data/users/swei/Dataset/jedi-data/bkg'
date ='2021080506'
fc_length = timedelta(hours=6)
init_date = pd.to_datetime(date,format='%Y%m%d%H') - fc_length
step = 'PT6H'
model = 'gfs_aero'
expr = 'oper'

#resol = 'c90'
#filetypes = ['bkg_clcv', 'abkg.eta']
#basename = []
#for file in filetypes:
#    bkgfile = file+'.'+init_date.strftime('%Y%m%d%H')+'.'+step+'.nc'
#    bkgfilepath = os.path.join(savedir,bkgfile)
#    basename.append(bkgfilepath)

conf = {
        'model': model,
        'expr': expr,
        'init_date': init_date.strftime('%Y-%m-%dT%H:00:00Z'),
        'step': step,
        #'filetypes': filetypes,
        #'basename': basename,
        #'resolution': resol,
        }

resultlist=R2D2Data.search(
    item='forecast',
    model=conf['model'],
    experiment=conf['expr'],
    step=conf['step'],
    date=conf['init_date'],
    member=member,
)

for item in resultlist:
    print(item)
    if not fetch:
        continue
   
    if item['file_extension']!='':
        suffix = '.'+item['file_extension']
    else:
        suffix = item['file_extension']

    if item['tile']==-9999:
        bkgfile = item['file_type']+'.'+item['date'].strftime('%Y%m%d%H')+'.'+item['step']+suffix
    else:
        bkgfile = item['file_type']+'.'+item['date'].strftime('%Y%m%d%H')+'.'+item['step']+'.tile'+str(item['tile'])+suffix
    
    save_filename = os.path.join(savedir,bkgfile)
    if os.path.exists(save_filename):
        print('Skipped')
        continue
    print('Saving to '+save_filename)

    R2D2Data.fetch(
        model=item['model'],
        item='forecast',
        experiment=item['experiment'],
        step=item['step'],
        resolution=item['resolution'],
        date=item['date'],
        tile=item['tile'],
        target_file=f'{save_filename}',
        file_extension=item['file_extension'],
        file_type=item['file_type'],
        member=item['member'],
    )

