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
#path='/data/users/swei/resultcheck/R2O_work/DiagFiles/input_diag'
txtpath='/data/users/swei/resultcheck/R2O_work/DiagFiles/GSI_DiagPackage/output'
outpath='/data/users/swei/archive/nc_DiagFiles'

''' ! radiance bias correction terms are as follows:
!  pred(1,:)  = global offset
!  pred(2,:)  = zenith angle predictor, is not used and set to zero now
!  pred(3,:)  = cloud liquid water predictor for clear-sky microwave radiance assimilation
!  pred(4,:)  = square of temperature laps rate predictor
!  pred(5,:)  = temperature laps rate predictor
!  pred(6,:)  = cosinusoidal predictor for SSMI/S ascending/descending bias
!  pred(7,:)  = sinusoidal predictor for SSMI/S
!  pred(8,:)  = emissivity sensitivity predictor for land/sea differences
!  pred(9,:)  = fourth order polynomial of angle bias correction
!  pred(10,:) = third order polynomial of angle bias correction
!  pred(11,:) = second order polynomial of angle bias correction
!  pred(12,:) = first order polynomial of angle bias correction  '''

#explist=['test']
explist=['prctrl']
#sensorlist=['hirs2_n14','msu_n14','sndr_g08','sndr_g11','sndr_g12','sndr_g13',
#            'sndr_g08_prep','sndr_g11_prep','sndr_g12_prep','sndr_g13_prep',
#            'sndrd1_g11','sndrd2_g11','sndrd3_g11','sndrd4_g11','sndrd1_g12',
#            'sndrd2_g12','sndrd3_g12','sndrd4_g12','sndrd1_g13','sndrd2_g13',
#            'sndrd3_g13','sndrd4_g13','sndrd1_g14','sndrd2_g14','sndrd3_g14',
#            'sndrd4_g14','hirs3_n15','hirs3_n16','hirs3_n17','amsua_n15','amsua_n16',
#            'amsua_n17','amsub_n15','amsub_n16','amsub_n17','hsb_aqua','amsua_aqua',
#            'imgr_g08','imgr_g11','imgr_g12','imgr_g14','imgr_g15','ssmi_f13','ssmi_f15',
#            'amsua_n18','amsua_metop-a','mhs_n18','mhs_metop-a','amsre_low_aqua','amsre_mid_aqua',
#            'amsre_hig_aqua','ssmis_f16','ssmis_f17','ssmis_f18','ssmis_f19','ssmis_f20',
#            'amsua_n19','mhs_n19','seviri_m09','cris-fsr_npp','atms_npp','amsua_metop-b',
#            'mhs_metop-b','amsr2_gcom-w1','gmi_gpm','saphir_meghat','ahi_himawari8',
#            'airs_aqua','avhrr_metop-a','avhrr_n18','cris_npp','hirs4_metop-a','hirs4_metop-b',
#            'hirs4_n19','iasi_metop-a','iasi_metop-b','seviri_m08','seviri_m10','sndrd1_g15',
#            'sndrd2_g15','sndrd3_g15','sndrd4_g15']
#sensorlist=['airs_aqua','avhrr_metop-a','avhrr_n18','cris_npp','hirs4_metop-a','hirs4_metop-b',
#            'hirs4_n19','iasi_metop-a','iasi_metop-b','seviri_m08','seviri_m10','sndrd1_g15',
#            'sndrd2_g15','sndrd3_g15','sndrd4_g15']
#sensorlist=['airs_aqua','amsua_aqua','amsua_metop-a','amsua_n15','amsua_n18','amsua_n19',
#            'atms_npp','avhrr_metop-a','avhrr_n18','cris_npp','hirs4_metop-a','hirs4_metop-b',
#            'hirs4_n19','iasi_metop-a','iasi_metop-b','mhs_metop-a','mhs_metop-b','mhs_n18',
#            'mhs_n19','seviri_m08','seviri_m10','sndrd1_g15','sndrd2_g15','sndrd3_g15',
#            'sndrd4_g15','ssmis_f17','ssmis_f18']
sensorlist=['iasi_metop-a']
looplist=['ges']#,'anl'] #ges,anl

sdate=2017080512
edate=2017080512

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
    for sensor in sensorlist:
        d=0
        for date in dlist:
            for loop in looplist:
                raddfile='diag_'+sensor+'_'+loop+'.'+date
                print('Processing Radfile: %s for %s' %(raddfile,exp))
                infile1=path+'/'+exp+'/'+raddfile
                #infile1=path+'/'+date+'/'+exp+'/'+raddfile
                if ( not os.path.exists(infile1)):
                   print('Warning: %s is not available'%(infile1))
                   continue
            
                nchanl1,npred1,nobs1,nreal1=rd.read_radhead(infile1)
                freq1,pol1,wave1,varch1,tlap1,iuse_rad1,nuchan1,ich1,locinfo1,tb_obs1,tbc1,tbcnob1,errinv1,qcflag1,emiss1,tlapchn1,ts1,pred1=rd.load_raddata(
                       infile1,nchanl1,npred1,nobs1,nreal1)
                 
#                locinfo=txtpath+'/'+exp+'/'+date+'/'+sensor+'/result_'+loop+'_locinfo'
#                if ( not os.path.exists(locinfo)):
#                   print('Warning: %s is not available'%(locinfo))
#                   continue
#
#                locf=open(locinfo,'r')
#                total_aod=[]; dufrac=[]; ssfrac=[]; sufrac=[]; bcfrac=[]; ocfrac=[]
#                for line in locf:
#                    total_aod.append(float(line.split()[3]))
#                    dufrac.append(float(line.split()[4]))
#                    ssfrac.append(float(line.split()[5]))
#                    sufrac.append(float(line.split()[6]))
#                    bcfrac.append(float(line.split()[7]))
#                    ocfrac.append(float(line.split()[8]))
#                total_aod=np.array(total_aod)
#                dufrac=np.array(dufrac)
#                ssfrac=np.array(ssfrac)
#                sufrac=np.array(sufrac)
#                bcfrac=np.array(bcfrac)
#                ocfrac=np.array(ocfrac)
#                if ( total_aod.size != nobs1):
#                   print('Error: AOD info is not available in %s'%(locinfo))
#                   continue
                
                ds=xa.Dataset({'freq':(['channel'],freq1),
                               'pol':(['channel'],pol1),
                               'wavenumber':(['channel'],wave1),
                               'varch':(['channel'],varch1),
                               'tlap1':(['channel'],tlap1),
                               'iuse_rad':(['channel'],iuse_rad1),
                               'nuchan':(['channel'],nuchan1),
                               'ich':(['channel'],ich1),
                               'locinfo':(['nreal','obsloc'],locinfo1),
#                               'aod':(['obsloc'],total_aod),
#                               'dufrac':(['obsloc'],dufrac),
#                               'ssfrac':(['obsloc'],ssfrac),
#                               'sufrac':(['obsloc'],sufrac),
#                               'bcfrac':(['obsloc'],bcfrac),
#                               'ocfrac':(['obsloc'],ocfrac),
                               'tb_obs':(['channel','obsloc'],tb_obs1),
                               'tbc':(['channel','obsloc'],tbc1),
                               'tbcnob':(['channel','obsloc'],tbcnob1),
                               'errinv':(['channel','obsloc'],errinv1),
                               'qcflag':(['channel','obsloc'],qcflag1),
                               'emissivity':(['channel','obsloc'],emiss1),
                               'tlapchan':(['channel','obsloc'],tlapchn1),
                               'ts':(['channel','obsloc'],ts1),
                               'predbias':(['channel','npred','obsloc'],pred1)},
                                coords={'obsloc':np.arange(nobs1),
                                        'channel':np.arange(nchanl1),
                                        'nreal':np.arange(nreal1),
                                        'npred':np.arange(npred1+2),
                                        'analysis_time':pddates[d]},
                                attrs={'Sensor':sensor,'Reference Time':date,'Loop':loop})
                #ds.to_netcdf(outpath+'/'+exp+'/'+raddfile+'.nc')
                ds.to_netcdf('./'+raddfile+'.nc')
            d=d+1
            
