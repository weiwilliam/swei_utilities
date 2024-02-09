#!/usr/bin/env python3
import os,sys
#r2d2dir = '/work2/noaa/jcsda/shihwei/skylab/jedi-bundle/r2d2/src/r2d2'
#os.environ["PYTHONPATH"] = r2d2dir + ':' + os.environ["PYTHONPATH"]
from r2d2 import R2D2Data

member = R2D2Data.DEFAULT_INT_VALUE
print(member)

class r2d2utils(object):
    def __init__(self, indict):
        self.search_date = indict['date']
        self.item = indict['item']
        self.resol = indict['resolution']
        self.expr = indict['experiment']
        self.model = indict['model']
        self.step = indict['step']
        self.member = indict['member']
        self.task = indict['task']
        if self.task=='list':
            self._list()
        elif self.task=='fetch':
            self._fetch()

    def _list(self):
        resultlist=R2D2Data.search(
            item=self.item,
            model=self.model,
            experiment=self.expr,
            file_extension='nc',
            #resolution=resolution,
            #file_type='abkg.eta',
            #file_type='bkg_clcv',
            step='PT6H',
            date=date,
            member=member,
        )
        
        for item in resultlist:
            print(item)
    return
    
    def fetchdata():
        outputpath = savedir + '/' + date
        if ( not os.path.exists(outputpath) ):
            os.makedirs(outputpath)
        
        R2D2Data.fetch(item='forecast',
            model='geos',
            experiment='oper',
            file_extension='nc',
            resolution='c90',
            file_type=filetype,
            step=step,
            date=date,
            target_file=f'{savedir}/{date}/{model}.{filetype}.{date}.{step}.nc'
        )
    return

if __name__ == '__main__':
    savedir = '/work2/noaa/jcsda/shihwei/data/geos'
    date = '20210805T060000Z'
    step = 'PT6H'
    filetype = 'abkg.eta'
    model = 'geos'
    date = '20210823T120000Z'
    resolution = 'c90'
