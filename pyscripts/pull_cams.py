#!/usr/bin/env python3
import os,sys
from utils import get_dates
import cdsapi

savepath='/data/users/swei/MAPP/model/cams_pm25'

sdate=2016010100
edate=2016010118
hint=24

dates = get_dates(sdate,edate,hint)

for cdate in dates:
    c = cdsapi.Client()
    cpdy = cdate.strftime('%Y%m%d')
    
    filename = 'cams_pm25.'+cpdy+'.nc'
    outputfile = os.path.join(savepath,filename)
    c.retrieve(
        'cams-global-reanalysis-eac4',
        {
            'date': '2016-01-01/2016-12-31',
            'format': 'netcdf',
            'variable': 'particulate_matter_2.5um',
            'time': [
                '00:00', '03:00', '06:00',
                '09:00', '12:00', '15:00',
                '18:00', '21:00',
            ],
        },
        outputfile)
