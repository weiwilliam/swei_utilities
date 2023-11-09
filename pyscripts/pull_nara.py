#!/usr/bin/env python3

import subprocess as sp
from utils import get_dates 

narapath = 'https://esrl.noaa.gov/gsd/thredds/fileServer/retro/global_aerosol_reanalysis'
#201601/NARA-1.0_AOD_2016010100.nc4'
savepath = '/data/users/swei/MAPP/model/nara'

sdate = 2016010200
edate = 2016123118
hint = 6

dates = get_dates(sdate,edate,hint)

tmplist = savepath+'/tmplist'
f = open(tmplist,'w')

for cdate in dates:
    cyy = cdate.strftime('%Y')
    cmm = cdate.strftime('%m')
    cdstr = cdate.strftime('%Y%m%d%H')
    narafile = '%s/%s%s/NARA-1.0_AOD_%s.nc4\n' %(narapath,cyy,cmm,cdstr)
    f.write(narafile)

f.close()
sp.run(['wget','-i',tmplist,'-P',savepath])
