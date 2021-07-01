#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 21 21:59:35 2019

@author: weiwilliam
"""
import os
import sys
sys.path.append('/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/PythonScripts/libs')
import read_gsidiag as rd
import numpy as np
import time
from datetime import datetime
from datetime import timedelta
import xarray as xa
import pandas as pd

path='/data/users/swei/archive/DiagFiles'
outpath='/data/users/swei/archive/nc_DiagFiles'

looplist=['ges','anl'] #ges,anl
explist=['praero']#'prctrl','prctrl_anal2']#,'praero']
varlist=['ps','t','q','gps','sst','uv','tcp']

generalscripts=('itype=1,lat=3,lon=4,pres=6,time=8,iusev=11,iuse=12,'+
                'inverse obs err=16, ')
gpsscripts=('impact height=7,'+
            'used_inv=17(bending angle in rad)*5(obs-ges in %),temp=18,sh=21')
otherscripts=('obs=17,inv=18')
uvscripts=('uobs=17,u_inv=18,vobs=20,v_inv=21')

sdate=2017080100
edate=2017080100

def ndate(cdate,hinc):
    yy=int(str(cdate)[:4])
    mm=int(str(cdate)[4:6])
    dd=int(str(cdate)[6:8])
    hh=int(str(cdate)[8:10])
    dstart=datetime(yy,mm,dd,hh)
    dnew=dstart+timedelta(hours=hinc)
    dnewint=int(str('%4.4d' % dnew.year)+str('%2.2d' % dnew.month)+
                str('%2.2d' %dnew.day)+str('%2.2d' % dnew.hour))
    return dnewint

syy=int(str(sdate)[:4]); smm=int(str(sdate)[4:6])
sdd=int(str(sdate)[6:8]); shh=int(str(sdate)[8:10])
eyy=int(str(edate)[:4]); emm=int(str(edate)[4:6])
edd=int(str(edate)[6:8]); ehh=int(str(edate)[8:10])

date1 = datetime(syy,smm,sdd,shh)
date2 = datetime(eyy,emm,edd,ehh)
delta = timedelta(hours=6)
pddates= pd.date_range(start=date1,end=date2,freq=delta)

tnum=0
dlist=[]
cdate=sdate
while (cdate<=edate):
    dlist.append(str(cdate))
    tnum=tnum+1
    cdate=ndate(cdate,6)

for exp in explist:
    d=0
    for date in dlist:
        archdir=outpath+'/'+exp+'/'+date
        if ( not os.path.exists(archdir) ):
            os.makedirs(archdir)
        for loop in looplist:
            cnvdfile='diag_conv_'+loop+'.'+date
            print('Processing Conv file: %s for %s' %(cnvdfile,exp))
            infile1=path+'/'+exp+'/'+date+'/'+cnvdfile
            if ( not os.path.exists(infile1)):
               print('Warning: %s is not available'%(infile1))
               continue

            (nrecs,varnlist,psnreal,tnreal,qnreal,gpsnreal,sstnreal,uvnreal,tcpnreal,
             psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum) = rd.read_cnvhead(infile1)

            (ps_stid,ps_data,t_stid,t_data,q_stid,q_data,gps_stid,gps_data,
             sst_stid,sst_data,uv_stid,uv_data,tcp_stid,tcp_data
             ) = rd.load_cnvdata(infile1,nrecs,varnlist,psnreal,tnreal,qnreal,gpsnreal,
             sstnreal,uvnreal,tcpnreal,psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum)
            
            #maxnreal=np.max((psnreal,tnreal,qnreal,gpsnreal,sstnreal,uvnreal,tcpnreal))
            #obsnum=np.sum((psnum,tnum,qnum,gpsnum,sstnum,uvnum,tcpnum))
       
            for var in varlist:
                if (var=='ps'):
                   nreal= psnreal
                   obsnum=psnum
                   stid  =ps_stid
                   data  =ps_data
                if (var=='t'):
                   nreal= tnreal
                   obsnum=tnum
                   stid  =t_stid
                   data  =t_data
                if (var=='q'):
                   nreal= qnreal
                   obsnum=qnum
                   stid  =q_stid
                   data  =q_data
                if (var=='gps'):
                   nreal= gpsnreal
                   obsnum=gpsnum
                   stid  =gps_stid
                   data  =gps_data
                if (var=='sst'):
                   nreal= sstnreal
                   obsnum=sstnum
                   stid  =sst_stid
                   data  =sst_data
                if (var=='uv'):
                   nreal= uvnreal
                   obsnum=uvnum
                   stid  =uv_stid
                   data  =uv_data
                if (var=='tcp'):
                   nreal= tcpnreal
                   obsnum=tcpnum
                   stid  =tcp_stid
                   data  =tcp_data
                cnvdfile_out='diag_conv_'+var+'_'+loop+'.'+date
                
                vararr=[]
                for i in np.arange(obsnum):
                    vararr.append(var)
                vararr=np.array(vararr)
                tmpstid=[]
                for i in np.arange(obsnum):
                    tmpstid.append(stid[i].tostring().decode())
                tmpstid=np.array(tmpstid)
                #obsdata=np.zeros((nreal,obsnum),dtype='float')
                #obsdata[:nreal,sidx:eidx]=data
                #sidx=eidx
                ds=xa.Dataset({'vartype':(['obsloc'],vararr),
                           'stid':(['obsloc'],tmpstid),
                           'obsdata':(['nreal','obsloc'],data)},
                           coords={'obsloc':np.arange(obsnum),
                                   'nreal':np.arange(nreal)},
                           attrs={'general':generalscripts,
                                  'gps':gpsscripts,
                                  'ps,t,q,sst,tcp':otherscripts,
                                  'uv':uvscripts,
                                  'Reference Time':date,'Loop':loop})
                ds.to_netcdf(archdir+'/'+cnvdfile_out+'.nc')
                ds.close()
                del(stid,data)
        d=d+1
            
