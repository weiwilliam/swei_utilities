import os,sys, platform
os_name=platform.system()
if (os_name=='Darwin'):
    rootpath='/Users/weiwilliam'
    rootarch='/Volumes/WD2TB/ResearchData'
elif (os_name=='Windows'):
    rootpath='F:\GoogleDrive_NCU\Albany'
    rootarch='F:\ResearchData'
    rootgit='F:\GitHub\swei_research'
elif (os_name=='Linux'):
    if (os.path.exists('/scratch1')):
        rootpath='/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei'
        rootarch='/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/ResearchData'
        rootgit='/home/Shih-wei.Wei/research'
    elif (os.path.exists('/glade')):
        rootpath='/glade/work/swei/output/images'
        rootarch='/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/ResearchData'
        rootgit='/glade/u/home/swei/research'
        machine='Cheyenne'
    elif (os.path.exists('/s4home')):
        rootpath='/data/users/swei/Images'
        rootarch='/scratch2/BMC/gsd-fv3-dev/Shih-wei.Wei/ResearchData'
        rootgit='/home/swei/research'
        machine='S4'
sys.path.append(rootgit+'/pyscripts/functions')
from utils import ndate
import cdsapi

if (machine=='S4'):
   downloadpath='/data/users/swei/common/ERA5'

sdate=2020062100
edate=2020071418
hint=6

dlist=[]
cdate=sdate
while (cdate<=edate):
    dlist.append(str(cdate))
    cdate=ndate(hint,cdate)

c = cdsapi.Client()

for date in dlist:
    yy=date[:4];  mm=date[4:6]
    dd=date[6:8]; hh=date[8:10]
    filename='era5_'+date+'.grib'
    hhstr=hh+':00'
    savepath=os.path.join(downloadpath,yy,mm)
    if (not os.path.exists(savepath)):
        os.makedirs(savepath)
    outputgrib=os.path.join(savepath,filename)
    c.retrieve(
        'reanalysis-era5-pressure-levels',
        {
            'product_type': 'reanalysis',
            'format': 'grib',
            'variable': [
                'geopotential', 'relative_humidity', 'specific_humidity',
                'temperature', 'u_component_of_wind', 'v_component_of_wind',
            ],
            'pressure_level': [
                '1', '2', '3',
                '5', '7', '10',
                '20', '30', '50',
                '70', '100', '125',
                '150', '175', '200',
                '225', '250', '300',
                '350', '400', '450',
                '500', '550', '600',
                '650', '700', '750',
                '775', '800', '825',
                '850', '875', '900',
                '925', '950', '975',
                '1000',
            ],
            'year': yy,
            'month': mm,
            'day': dd,
            'time': hhstr,
        },
        outputgrib)
